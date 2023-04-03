import traceback
import json


def load_settings():
    # if settings.json does not exist, create one
    with open("settings.json", "w") as json_file:
        json.dump({}, json_file)
    try:
        with open("settings.json", "r") as json_file:
            global settings
            settings = json.load(json_file)
            print(settings)

    except:
        print("Unable to load Settings file.")
        print(traceback.format_exc())


def save_settings(key, value):
    global settings
    try:
        with open("settings.json", "r") as json_file:
            settings = json.load(json_file)
            settings[key] = value
            print(f"setting[{key}] = {value}")
        with open("settings.json", "w") as json_file:
            json_object = json.dumps(settings, indent=4)
            json_file.write(json_object)
    except:
        print("Unable to load JSON file.")
        print(traceback.format_exc())


def get_settings(key):
    try:
        return settings[key]
    except:
        print(f"setting[{key}] is not found.")
        #print(traceback.format_exc())
        return ''


settings = None
