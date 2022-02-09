# GitLab Environment Toolkit Test Suite

This folder contains scripts and tooling to perform an end-to-end smoke tests for GET.

## Folder structure

The `ref-archs` folder is containing the architectures that will be prompted during the test.

A folder for each support cloud provider will be in this folder too, containing a dedicated script to perform the test.

## Requirements

To run the test script you need to have on your local environment:

- gitlab-qa ruby gem
- ssh-keygen

## Test execution

The plain test can be performed cloning this project, moving the chosen provider folder and launching the bash script without any argument from that folder.

Running the script with `-h` will provide additional options.

**Note:** To perform the test the same requirements needed to use the GET as normal will be required. See the main documentation for further info.

i.e.

```
cd test/aws
./get-aws-hybrid-test.sh
```
