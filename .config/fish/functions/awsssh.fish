function awsssh
    ssh -L 9229:localhost:9229 -L 9222:localhost:9222 -L 9000:localhost:9000 -L 8080:localhost:8080 -L 3001:locahost:3000 ubuntu@www.divsharp.com
end
