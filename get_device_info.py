
import argparse
import sys
import json
import os

parser = argparse.ArgumentParser(description = "Device info fetcher from JSON config")
parser.add_argument("-i", "--input", dest="input", action="store", help="Path to input file", required=True)
parser.add_argument("-o", "--output", dest="output_directory", action="store", help="Path to output directory", required=True)

args, rest = parser.parse_known_args()


def main():
    print ("Getting SOC informations")
    with open(args.input) as config_file:
        config = json.loads(config_file.read())
    if not os.path.exists(args.output_directory):
        os.makedirs(args.output_directory)

    with open(args.output_directory + "/device.cmake", "w") as cmake:
        for key in config["info"]:
            cmake.write("set ({key} {value} CACHE INTERNAL \"\" FORCE)\n".format(key = key, value = config["info"][key]))
        cmake.write("set_property (DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS {path})\n".format(path = args.input))

if __name__ == '__main__':
    main()
