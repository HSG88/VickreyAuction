from random import randint
import hashlib

if __name__ == '__main__':
    f = open('data.txt','w')
    for i in range(0,100):
        x = randint(1000,1500)
        s = hashlib.sha256()
        s.update(str(x))
        c = int(s.hexdigest(),16)
        f.write(str(x)+'\n'+str(c)+'\n')
    f.close()
        
