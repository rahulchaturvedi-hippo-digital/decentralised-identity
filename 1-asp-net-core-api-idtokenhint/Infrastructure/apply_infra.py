import subprocess
import sys
import shutil

# Terraform directory
TERRAFORM_DIR = "./azure"  # adjust to your Terraform code folder

def check_terraform():
    """Check if Terraform binary is available"""
    if shutil.which("terraform") is None:
        print("Error: Terraform not found in PATH.")
        sys.exit(1)

def parse_cli_args(args):
    """
    Parse terrform variable arguments into a dict
    """
    tf_vars = {}
    command = args[0]
    for arg in args:
        if "=" in arg:
            key, value = arg.split("=", 1)
            tf_vars[key] = value
    return command, tf_vars

def run_and_stream_command(cmd):
    """Run a command and stream its output"""
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    for line in process.stdout:
        print(line, end='')

    process.wait()
    process.stdout.close()
    
    return process
    

def run_terraform_command(command, tf_vars=None):
    """Run Terraform command with optional variables"""
    cmd = ["terraform", f"-chdir={TERRAFORM_DIR}", command]

    # For 'apply' and 'destroy', auto-approve
    if command in ["apply", "destroy"]:
        cmd.append("-auto-approve")

    # Add -var flags
    if tf_vars and not command == "deploy":
        for key, value in tf_vars.items():
            cmd.append(f'-var={key}="{value}"')

    print(f"\nRunning: {' '.join(cmd)}\n")

    try:
        if command == "deploy":
            # Special handling for 'deploy' command
            init_cmd = ["terraform", f"-chdir={TERRAFORM_DIR}", "init"]
            result = run_and_stream_command(init_cmd)
            apply_cmd = ["terraform", f"-chdir={TERRAFORM_DIR}", "apply", "-auto-approve"]
            if tf_vars:
                for key, value in tf_vars.items():
                    apply_cmd.append(f'-var={key}="{value}"')
            result = run_and_stream_command(apply_cmd)
        else:
            result = run_and_stream_command(cmd)
    except subprocess.CalledProcessError as e:
        print("Terraform command failed!")
        print("STDOUT:\n", e.stdout)
        print("STDERR:\n", e.stderr)
        sys.exit(1)
        print("STDOUT:\n", result.stdout)
        print("STDERR:\n", result.stderr)

if __name__ == "__main__":
    check_terraform()

    # Parse CLI args
    command, tf_vars = parse_cli_args(sys.argv[1:])

    # Run Terraform command
    run_terraform_command(command, tf_vars)
