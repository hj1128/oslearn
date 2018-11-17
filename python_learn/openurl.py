import urllib2
contents = urllib2.urlopen("https://www.baidu.com").read()
print(contents)