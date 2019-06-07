import string

#check if a token passes the criteria for being an identifier
def identCheck(x):
    if (x[0] not in string.digits and all(c in list(string.ascii_lowercase+string.ascii_uppercase+string.digits) for c in x)) and (x not in lexemeDict.keys() or x in letters):
        return True
    elif x.find(';') != len(x)-1 and x[0] not in string.digits and any((c not in [string.ascii_lowercase+string.ascii_uppercase+string.digits]) for c in x):
        return False
    else:
        return True

# Create lists for tokens from the Lexeme categories
letters = list('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')

digits = list(string.digits)

keywords = ['char', 'int', 'main', 'bool', 'while']

operators = ['=','+','-','*','/','<=','>=','==','!=']

punctuation = [';',',','(',')','{','}',"'"]

boolean = ['true','false']

# create list of ASCii characters
ASCii = [x for x in string.printable if x not in letters + digits + operators + punctuation]

#build lexeme dictionary
tokens=letters+digits+keywords+operators+punctuation+boolean+ASCii
tokenType=list((['letter']*52)+(['digits']*10)+(['keyword']*5)+(['operator']*9)+(['punctuation']*7)+(['boolean']*2)+(['ASCii']*26))
lexemeDict=dict(zip(tokens, tokenType))

#Open and Read input/output files
inputFile = open('prog.txt','r')
outFile = open('tokens.txt', 'w')
lines = inputFile.readlines()
inputFile.close()
inFile=open('prog.txt', 'r')
newLines=inFile.read()

#empty lists to collect symbols and corresponding line numbers
symbolList=[]
symbolLine=[]

#write names of the table columns 
outFile.write('{0: <20}'.format('Token Type'))
outFile.write('Lexeme\n')

#print each token and it's type while adding any symbol and its line number to the corresponding list
for j in range(len(lines)):
    delimitedList=lines[j].split()
    for i in range(len(delimitedList)):
        try:
            if identCheck(delimitedList[i]) == True and delimitedList[i][0] == '\'' and delimitedList[i][2] == '\'':
                outFile.write('{0: <20}'.format('char'))
                outFile.write(delimitedList[i].replace('\'', '').replace(';', '')+'\n')
                outFile.write('{0: <20}'.format('punctuation'))
                outFile.write(';\n')
            elif identCheck(delimitedList[i]) == True and (delimitedList[i].replace(';', '') not in lexemeDict.keys() or delimitedList[i].replace(';', '') not in digits):
                outFile.write('{0: <20}'.format('identifier'))
                outFile.write(delimitedList[i].replace(';', '')+'\n')
                outFile.write('{0: <20}'.format('punctuation'))
                outFile.write(';\n')
                if delimitedList[i] not in symbolList:
                    symbolList.append(delimitedList[i].replace(';', ''))
                    symbolLine.append(j+1)
            elif identCheck(delimitedList[i]) == True and delimitedList[i].replace(';', '') in digits:
                outFile.write('{0: <20}'.format('integer'))
                outFile.write(delimitedList[i].replace(';', '')+'\n')
                outFile.write('{0: <20}'.format('punctuation'))
                outFile.write(';\n')
            else:
                outFile.write('{0: <20}'.format(lexemeDict[delimitedList[i]]))
                outFile.write(delimitedList[i])
                outFile.write('\n')
        except:
            outFile.write('{0: <20}'.format('unexpected char'))
            outFile.write(delimitedList[i]+'\n')

#create a dictionary of symbols and their line numbers found in the input file
symbolDict=dict(zip(symbolList, symbolLine))

#write the names of the table columns
outFile.write('\n'+('{0: <20}'.format('Symbol Table')))
outFile.write('Line Number\n')

#print each symbol and its line number
for i in range(len(symbolList)):
    outFile.write(('{0: <20}'.format(symbolList[i])))
    outFile.write(str(symbolDict[symbolList[i]])+'\n')

#close the file and exit
outFile.close()
