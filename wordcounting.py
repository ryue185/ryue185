import re

pip install syllapy

import syllapy

sentence_split = ['.','?','!','|']
pairs = ["'",'"','[',']','<','>','(',')','{','}']
alphabet = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
digit = ['0','1','2','3','4','5','6','7','8','9']

text = "The value is 32.7. The color is 'turquoise', visualization unachievable? The value's observation is complete!"
# this is a funky test case
text_lower = text.lower()
print(text_lower)

def toWords(input_text):
  words = re.findall(r"[\w']+|[/\.,!?;:'|]", input_text)
  return words

print(toWords(text))

def wordCount_nonNum(input_text):
  input_copy = input_text.lower()
  words_list = toWords(input_copy)
  count = 0
  for i in words_list:
    if(i[0] in alphabet or i[0] in pairs):
      count=count+1
  
  return count

print(wordCount_nonNum(text))

def wordCount(input_text):
  input_copy = input_text.lower()
  words_list = input_copy.split()
  return len(words_list)
  
print(wordCount(text))

def numSentences(input_text):
  ## one niche case this cannot account for: a sentence with '.' ends with an integer 
  ## while the next sentence begins with an integer
  input_copy = input_text.lower()
  words_list = toWords(input_copy)
  count = 0

  
  for j in range(len(words_list)):
    if(words_list[j] in sentence_split):
      count = count+1
    if((words_list[j][0] in digit) and j>=2):
      if(words_list[j-1][0]=='.' and (words_list[j-2][0] in digit)):
        count = count-1
          
  return count

numSentences(text)

def wordLenDis(input_text,pr=True):
  input_copy = input_text.lower()
  words_list = toWords(input_copy)
  sw_count = 0
  mw_count = 0
  lw_count = 0

  def readjust(i,count):
    if((words_list[i][0] in digit) and i>=2):
          if(words_list[i-1][0]=='.' and (words_list[i-2][0] in digit)):
            return count-1
    return count

  for i in range(len(words_list)):
    if((words_list[i][0] in alphabet) or words_list[i][0] in digit or words_list[i][0]=='"' or words_list[i][0]=="'"):
      if(len(words_list[i])<5 
         or ((words_list[i][0] in pairs) and len(words_list[i])<7)
         or (words_list[i][0]!="'" and ("'" in words_list[i]) and len(words_list[i])<6)):
        sw_count=sw_count+1
        sw_count = readjust(i,sw_count)

      elif(len(words_list[i])<10 
         or ((words_list[i][0] in pairs) and len(words_list[i])<12)
         or (words_list[i][0]!="'" and ("'" in words_list[i]) and len(words_list[i])<11)):
        mw_count+=1
        mw_count = readjust(i,mw_count) 

      else:
        lw_count+=1
        lw_count = readjust(i,lw_count) 
  if(pr):
    print("There are", sw_count, "short words")
    print("There are", mw_count, "mid-length words")
    print("There are", lw_count, "long words")
  
  return [sw_count,mw_count,lw_count]

wordLenDis(text,True)

def avg_Wordlen(input_text):
  input_copy = input_text.lower()
  words_list = toWords(input_copy)
  tot_len = 0
  for i in words_list:
    if(i[0] in pairs):
      tot_len += (len(i)-2)
    if(i[0] in alphabet):
      if("'" in i[0]):
        tot_len += (len(i)-1)
      else:
        tot_len += len(i) 

  return tot_len/wordCount_nonNum(input_text)

print(avg_Wordlen(text))

def hardWordCount(input_text):
  input_copy = input_text.lower()
  words_list = toWords(input_copy)
  count = 0
  for i in words_list:
    if(syllapy.count(i)>=3):
      count+=1
  return count

hardWordCount(text)

def FOG(input_text):
  # why is this important? 
  # this is a measure of readability of text
  # and in Finance the FOG of 10Ks is shown to affect
  # analysts following, analysts responsiveness, and analysts response speed
  input_copy = input_text.lower()
  words_list = toWords(input_copy)
  wcount = wordCount(input_text)
  scount = numSentences(input_text)
  longwords = hardWordCount(input_text)
  return int(0.4*((wcount/scount)+longwords*100/wcount))

FOG(text)

essay_excerpt = "Though considered a radically new argument that marked the height of Enlightenment, Locke’s idea of the Separation of Church and State was very much rooted in Europe’s past. Historical trends that arose from the jumbling of temporal and spiritual power have created so much conflict that separating the two was necessary to maintain Europe’s religious peace and the individual’s liberty of conscience. The king’s role as the defender of the faith, the Protestant Reformation, and the constant power struggle between kings and Popes all provide the necessary historical context for understanding Locke’s arguments and are possibly what prompted him to make them. "
# this test case is an excerpt from one of my history essays
# using it to test whether my functions can handle longer passages with harder words
print(wordCount(essay_excerpt))
print(numSentences(essay_excerpt))
print(avg_Wordlen(essay_excerpt))
print(hardWordCount(essay_excerpt))
FOG(essay_excerpt)
