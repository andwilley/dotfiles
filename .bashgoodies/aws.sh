function awsssh() {
    ssh -L 9229:localhost:9229 -L 9222:localhost:9222 -L 9000:localhost:9000 -L 8080:localhost:8080 -L 3001:locahost:3000 ubuntu@www.divsharp.com;
}

function startec2() {
  aws ec2 start-instances --instance-ids "i-0256c137df484a73d"
}

function stopec2() {
  aws ec2 stop-instances --instance-ids "i-0256c137df484a73d"
}

function pingec2() {
  aws ec2 describe-instance-status --instance-ids "i-0256c137df484a73d" | python3 ~/Code/Scripts/aws.py
}
