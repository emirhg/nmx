
#import requests

#page = requests.post('http://www.economia-nmx.gob.mx/normasmx/consulta.nmx')
#
#{'requests-is': 'awesome'}
#print page.text.encode('utf-8')
#This will create a list of buyers:
#buyers = tree.xpath('//div[@title="buyer-name"]/text()')
#This will create a list of prices
#prices = tree.xpath('//span[@class="contenidoROJO"]/text()')

#print 'Buyers: ', buyers
#print 'Prices: ', prices

from pyvirtualdisplay import Display
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from lxml import html
 
display = Display(visible=0, size=(800, 600))
display.start()

def openFile(path,type):
    f = open(path,type)
    return f

def writeFile(f,text):
    f.write(text+ '\n')

def readFile(f):
    return f.readline()

def closeFile(f):
    f.close()
 
browser = webdriver.Firefox()
browser.get('http://www.economia-nmx.gob.mx/normasmx/index.nmx')
print browser.title
browser.find_element_by_name("clave").click()
browser.find_element_by_name("Image4").click()
print browser.page_source.encode('utf-8')

f=openFile("nmx-vigentes",'r+')
g=openFile("tabla-nmx-vigentes",'a')
y=readFile(f)
z=0
while y:
	print z
	z+=1
	text=""
	browser.get('http://www.economia-nmx.gob.mx/normasmx/detallenorma.nmx?clave='+y)
	browser.page_source.encode('utf-8')

	listBrowser = browser.find_elements_by_class_name("contenidoROJO")
	links =browser.find_element_by_css_selector( "a[href*='economia-nmx']" )
	#links = browser.find_element_by_partial_link_text("pdf")

	algo= str(z)+" , "+links.get_attribute('href')
	text=text+str(z)+" , "+links.get_attribute('href')
	for x in listBrowser:
		#print x.text.encode('utf-8')
		text=text +" , "+x.text
		pass
	text=text

	writeFile(g,text.encode('utf-8'))
	y=readFile(f)
	pass
closeFile(g)
closeFile(f)
browser.quit()
 
display.stop()