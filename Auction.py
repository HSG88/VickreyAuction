from pysnark.runtime import Var
from hashlib import sha256
import pysnark.prove

if __name__ == '__main__':
    f = open('data.txt','r')
    success = 1
    bids = []
    commits = []
    maxBid = 0
    
#Read bids and commitments from file data.txt
    for i in range (0,100):
        x = int(f.readline())
        y = int(f.readline())
#Verify commit y=sha256(x)
        s = sha256()
        s.update(str(x))
        if y <> int(s.hexdigest(),16):
            success = 0
            break
#Append bids as witnesses and commits as public variables
        bids.append(x)
        commits.append(Var(int(y),'C'+str(i)))
#Check for the winning bid
        if maxBid < x:
            maxBid = x
    #Var(maxBid, 'Winner')
    s = sha256()
    s.update(str(maxBid))
    Var(int(s.hexdigest(),16), 'HighestCommit')
    Var(success, 'Valid')
    
