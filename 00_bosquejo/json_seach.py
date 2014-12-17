#! /usr/bin/python3
import json

def find_values(id, json_repr):
    results = []

    def _decode_dict(a_dict):
        try: results.append(a_dict[id])
        except KeyError: pass
        return a_dict

    json.loads(json_repr, object_hook=_decode_dict)  # return value ignored
    return results

json_repr = '{"P1": "ss", "Id": 1234, "P2": {"P1": "cccc"}, "P3": [{"P1": "aaa"}]}'
print (find_values('P1', json_repr)	)
