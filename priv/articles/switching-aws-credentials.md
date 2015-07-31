
As documented in the this [Amazon blog post](http://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs), using `~/.aws/credentials` file is the recommended way to specify access credentials. However, legacy applications and/or scripts often rely on credentials being specified trough `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables. Specifying these variables in shell startup scripts works when you have only one AWS account, but doesn't scale to multiple accounts.

My solution was to use combination of a python and [zsh](http://www.zsh.org/) to implement `awse` command, which reads credentials from `~/aws/credentials` file and exports `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables. 

__example usage__
```bash
$> awse dev
Setting AWS authentication to env: "dev" key_id: "abcd..." access_key: "vUOOB..."

$> awse
Clearing AWS authentication
```

The `./aws/credentials` file is an `.ini` file, with sections and keys. The section name is the profile name and `aws_access_key_id` and `aws_secret_access_key` keys specify credentials.

__~/.aws/credentials example with dev and prod profiles__
```ini
[dev]
aws_access_key_id = ABCD12345
aws_secret_access_key = ****************************************

[prod]
aws_access_key_id = ********************
aws_secret_access_key = ****************************************
```

Reading the credentials is easy with python and ConfigParser class. I wrote a small python script which takes two parameters, profile name and key. If the ~/.aws/credentials contains matching section and key, it prints out the value.

__parse_aws_credentials.py__
```Python
#!/usr/bin/python
import sys, ConfigParser, os

if len(sys.argv) == 3:
    profile = sys.argv[1]
    key = sys.argv[2]
    config = ConfigParser.ConfigParser()
    config.read([os.path.expanduser('~/.aws/credentials')])

    if config.has_option(profile, key):
        print config.get(profile, key)
```

Setting environment variables for the calling shell process is not possible, since a child process can't change parent process environment. Therefore we write a native `zsh` function called awse which uses the python script for reading credentials. If the awse command is run without arguments, it clears the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables. If given a valid profile, it will export the credentials. I also update the AWS_ENV environment variable with the current profile name, so that I can use it in custom prompt to show currently active profile.

__.zshrc__
```
function awse {
    if [[ $# == 0 ]]; then
        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_ENV
        echo Clearing AWS authentication
        export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_ENV
    else
        local KEY_ID=$(parse_aws_credentials.py $1 AWS_ACCESS_KEY_ID)
        local ACCESS_KEY=$(parse_aws_credentials.py $1 AWS_SECRET_ACCESS_KEY)

        if [[ $KEY_ID == "" || $ACCESS_KEY == "" ]]; then
            echo No aws profile found for env $1 or all credentials not set
        else
            AWS_ACCESS_KEY_ID=$KEY_ID
            AWS_SECRET_ACCESS_KEY=$ACCESS_KEY
            AWS_ENV=$1
            echo Changed AWS profile to: $AWS_ENV
            echo key_id: $AWS_ACCESS_KEY_ID
            echo access_key: $AWS_SECRET_ACCESS_KEY[0,5]...
            export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_ENV
        fi
    fi
}
```

Final step was to show the current AWS profile if set. For that I modified my prompt to write `[profile]` if the AWS_ENV environment variable is set.

__modified__ __prompt__
```
if [[ -n "$AWS_ENV" ]]; then
    RPROMPT+='%F{3}[${AWS_ENV}]%f'
fi
```


