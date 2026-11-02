"""Bridge between the local vdirsyncer task mirror and Claude's to-do artifact.

  tasks-bridge snapshot          print every task as JSON, keyed by UID
  tasks-bridge apply QUEUE.json  apply queued changes, print a JSON report

The mirror is the vdirsyncer "filesystem" storage: one directory per Nextcloud
list (with a `displayname` file next to the items) and one .ics file per task.
Run `vdirsyncer sync` before and after; this script never talks to the network.

Queue entries (a JSON list, applied in order):
  {"op": "add", "list": "Personal", "summary": "...",
   "priority": "high|medium|low|none", "due": "2026-11-04", "notes": "..."}
  {"op": "update", "uid": "...", "seen": "<modified from the snapshot>",
   "summary"/"priority"/"due"/"notes"/"list": ...}   (due: null clears it)
  {"op": "complete", "uid": "...", "seen": "..."}
  {"op": "reopen", "uid": "...", "seen": "..."}
  {"op": "delete", "uid": "...", "seen": "..."}

"seen" is the task's `modified` value when the change was queued. If the task
has changed since (on the phone, say), the change is skipped, not guessed at.
Recurring tasks are read-only here: Tasks.org handles their completion.
"""

import datetime as dt
import json
import os
import sys
import tempfile
import uuid
from pathlib import Path

from icalendar import Calendar, Todo

BASE = Path(
    os.environ.get(
        "TASKS_BRIDGE_DIR",
        Path.home() / ".local/share/calendars/nextcloud",
    )
)

# Tasks.org's mapping onto iCalendar PRIORITY (RFC 5545: 1 highest, 0 none)
PRIORITY_IN = {"high": 1, "medium": 5, "low": 9, "none": 0}


def priority_label(value):
    value = int(value or 0)
    if value == 0:
        return "none"
    if value <= 4:
        return "high"
    if value == 5:
        return "medium"
    return "low"


def now():
    return dt.datetime.now(dt.timezone.utc).replace(microsecond=0)


def iso(value):
    if value is None:
        return None
    value = value.dt if hasattr(value, "dt") else value
    return value.isoformat()


def parse_due(text):
    """'2026-11-04' is a date; anything with a time is a datetime."""
    if text is None:
        return None
    if "T" in text:
        return dt.datetime.fromisoformat(text)
    return dt.date.fromisoformat(text)


def lists():
    """Map each list's display name (and directory name) to its directory."""
    found = {}
    if not BASE.is_dir():
        return found
    for d in sorted(p for p in BASE.iterdir() if p.is_dir()):
        name_file = d / "displayname"
        name = name_file.read_text().strip() if name_file.exists() else ""
        found[name or d.name] = d
        found.setdefault(d.name, d)
    return found


def display_name(directory):
    name_file = directory / "displayname"
    if name_file.exists() and name_file.read_text().strip():
        return name_file.read_text().strip()
    return directory.name


def load(path):
    cal = Calendar.from_ical(path.read_bytes())
    todos = [c for c in cal.walk() if c.name == "VTODO"]
    return cal, (todos[0] if todos else None)


def items():
    """Yield (path, calendar, vtodo) for every task file in the mirror."""
    for directory in sorted(set(lists().values())):
        for path in sorted(directory.glob("*.ics")):
            cal, todo = load(path)
            if todo is not None:
                yield path, cal, todo


def modified(todo):
    stamp = todo.get("last-modified") or todo.get("dtstamp")
    return iso(stamp)


def as_dict(path, todo):
    status = str(todo.get("status", "NEEDS-ACTION"))
    return {
        "uid": str(todo.get("uid")),
        "list": display_name(path.parent),
        "summary": str(todo.get("summary", "")),
        "priority": priority_label(todo.get("priority")),
        "due": iso(todo.get("due")),
        "notes": str(todo.get("description", "")) or None,
        "done": status == "COMPLETED",
        "completed": iso(todo.get("completed")),
        "recurring": "rrule" in todo,
        "modified": modified(todo),
    }


def write_atomic(path, cal):
    fd, tmp = tempfile.mkstemp(dir=path.parent, suffix=".tmp")
    with os.fdopen(fd, "wb") as f:
        f.write(cal.to_ical())
    os.replace(tmp, path)


def touch(todo):
    stamp = now()
    for key in ("last-modified", "dtstamp"):
        if key in todo:
            del todo[key]
    todo.add("last-modified", stamp)
    todo.add("dtstamp", stamp)


def set_field(todo, key, value):
    if key in todo:
        del todo[key]
    if value not in (None, ""):
        todo.add(key, value)


def apply_fields(todo, change):
    if "summary" in change:
        set_field(todo, "summary", change["summary"])
    if "notes" in change:
        set_field(todo, "description", change["notes"])
    if "priority" in change:
        level = PRIORITY_IN[change["priority"]]
        set_field(todo, "priority", level or None)
    if "due" in change:
        set_field(todo, "due", parse_due(change["due"]))


def find(uid):
    for path, cal, todo in items():
        if str(todo.get("uid")) == uid:
            return path, cal, todo
    return None


def snapshot():
    tasks = [as_dict(path, todo) for path, _cal, todo in items()]
    names = sorted({display_name(d) for d in lists().values()})
    report = {"synced_at": iso(now()), "lists": names, "tasks": tasks}
    json.dump(report, sys.stdout, indent=2)
    print()


def apply_one(change, touched):
    op = change.get("op")
    known = lists()

    if op == "add":
        target = known.get(change.get("list", ""))
        if target is None:
            return "skipped", f"no list named {change.get('list')!r}"
        uid = str(uuid.uuid4())
        todo = Todo()
        todo.add("uid", uid)
        todo.add("created", now())
        todo.add("status", "NEEDS-ACTION")
        apply_fields(todo, change)
        touch(todo)
        cal = Calendar()
        cal.add("prodid", "-//tasks-bridge//EN")
        cal.add("version", "2.0")
        cal.add_component(todo)
        write_atomic(target / f"{uid}.ics", cal)
        touched.add(uid)
        return "applied", uid

    hit = find(change.get("uid", ""))
    if hit is None:
        return "skipped", "task no longer exists"
    path, cal, todo = hit
    uid = str(todo.get("uid"))
    stale = change.get("seen") and modified(todo) != change["seen"]
    if stale and uid not in touched:
        return "skipped", "task changed since it was queued"
    if "rrule" in todo:
        return "skipped", "recurring task; change it in Tasks.org"

    touched.add(uid)
    if op == "delete":
        path.unlink()
        return "applied", None
    if op == "complete":
        set_field(todo, "status", "COMPLETED")
        set_field(todo, "completed", now())
        set_field(todo, "percent-complete", 100)
    elif op == "reopen":
        set_field(todo, "status", "NEEDS-ACTION")
        set_field(todo, "completed", None)
        set_field(todo, "percent-complete", None)
    elif op == "update":
        apply_fields(todo, change)
    else:
        return "skipped", f"unknown op {op!r}"
    touch(todo)

    new_list = change.get("list") if op == "update" else None
    if new_list and new_list != display_name(path.parent):
        target = known.get(new_list)
        if target is None:
            return "skipped", f"no list named {new_list!r}"
        write_atomic(target / path.name, cal)
        path.unlink()
    else:
        write_atomic(path, cal)
    return "applied", None


def apply(queue_file):
    queue = json.loads(Path(queue_file).read_text())
    results = []
    touched = set()  # tasks this run already changed; their "seen" is stale
    for index, change in enumerate(queue):
        try:
            status, detail = apply_one(change, touched)
        except Exception as exc:  # report it and keep going
            status, detail = "skipped", f"error: {exc}"
        results.append({"index": index, "status": status, "detail": detail})
    json.dump(results, sys.stdout, indent=2)
    print()


def main():
    if len(sys.argv) == 2 and sys.argv[1] == "snapshot":
        snapshot()
    elif len(sys.argv) == 3 and sys.argv[1] == "apply":
        apply(sys.argv[2])
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
