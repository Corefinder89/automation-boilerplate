import json
import os

def boilerplate_code():
    # Get configuration from json
    config_path = "config/config.json"
    current_working_dir = os.getcwd()

    with open(config_path, "r") as fileobj:
        jsondata = json.load(fileobj)

    # Get the project name to start with creating the root module
    project_name = ""
    for new_k in jsondata.get("root"):
        project_name = new_k
        break

    project_working_directory = current_working_dir+"/"+project_name
    print(project_working_directory)

    if os.path.exists(project_working_directory):
        # Create the project root directory
        os.mkdir(project_working_directory)
        # Make the project directory as a module by creating __init__.py if file does not exist
        with open(os.path.join(project_working_directory, "__init__.py"), "w") as fp:
            pass
    else:
        print("Project directory already exists")

boilerplate_code()