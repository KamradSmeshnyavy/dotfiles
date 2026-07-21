# SEC STUFF
alias gobust = gobuster dir --wordlist ~/security/wordlists/diccnoext.txt --wildcard --url
alias dirsearch = python dirsearch.py -w db/dicc.txt -b -u
alias massdns = ~/hacking/tools/massdns/bin/massdns -r ~/hacking/tools/massdns/lists/resolvers.txt -t A -o S bf-targets.txt -w livehosts.txt -s 4000
alias server = python -m http.server 4445
alias tunnel = ngrok http 4445
alias fuzz = ffuf -w ~/hacking/SecLists/content_discovery_all.txt -mc all -u
alias gr = ~/go/src/github.com/tomnomnom/gf/gf
