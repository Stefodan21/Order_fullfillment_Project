import json

def parse_event_body(event):
    raw = event.get('body', {})
    if isinstance(raw, str):
        try:
            return json.loads(raw)
        except json.JSONDecodeError:
            return {}
    return raw