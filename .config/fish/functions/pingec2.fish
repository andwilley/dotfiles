function pingec2
    aws ec2 describe-instance-status --instance-ids "i-0256c137df484a73d" | python3 ~/.bashgoodies/aws.py
end
