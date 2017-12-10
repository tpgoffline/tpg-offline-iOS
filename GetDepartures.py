from datetime import datetime
import json
import requests
from tqdm import tqdm
from time import sleep
from urllib.parse import quote
import sys
import argparse

class A:
	def waitHour(self, path="Departures/", jour="LUN"):
		while 1:
			if datetime.now().time().hour == 4 and datetime.now().time().minute == 20:
				break
			else:
				print(datetime.now().time())
				print("Attente de 4 heures 20")
				sleep(10)
		self.getDepartures(path, jour)

	def getDepartures(self, path="Departures/", jour="LUN"):
		arbre = json.loads(open("departures.json", "r").read())
		while 1:
			r = requests.get("http://prod.ivtr-od.tpg.ch/v1/GetStops.json?key=d95be980-0830-11e5-a039-0002a5d5c51b")
			if r.status_code == requests.codes.ok:
				break
			else:
				sleep(10)
		pbar = tqdm(r.json()["stops"])
		for x in pbar:
			pbar.set_description("Téléchargement de l'arret %s" % x["stopCode"])
			p = []
			r = requests.get("http://prod.ivtr-od.tpg.ch/v1/GetStops.json?key=d95be980-0830-11e5-a039-0002a5d5c51b&stopCode="+ x["stopCode"])
			m = r.json()["stops"][0]
			if m != None:
				for y in m["connections"]:
					parameters = {"key" : "d95be980-0830-11e5-a039-0002a5d5c51b", "stopCode" : x["stopCode"], "lineCode" : y["lineCode"], "destinationCode" : y["destinationCode"]}
					q = requests.get("http://prod.ivtr-od.tpg.ch/v1/GetAllNextDepartures.json", params=parameters)
					try:
						for z in q.json()["departures"]:
							p.append({"ligne" : z["line"]["lineCode"], "destination" : z["line"]["destinationName"], "timestamp" : z["timestamp"]})
					except Exception as e:
						print("Cant't download " + q.url)
			arbre[x["stopCode"] + jour + ".json"] = json.dumps({"departures": p}, separators=(',', ':'), ensure_ascii=False, sort_keys=True)
					
			file = open("departures.json", "w", encoding='utf8')
			file.write(json.dumps(arbre, sort_keys=True, indent=4, ensure_ascii=False))
			file.close()

a = A()
attendre = True
parser = argparse.ArgumentParser()
parser.add_argument("-dw", "--dontwait", help="Ne pas attendre 4h17 pour enregistrer les départs",
                    action="store_true")
parser.add_argument("-p", "--path", help="Changer l'endroit d'enregistrement des départs")
parser.add_argument("-d", "--day", help="Changer le jour")
args = parser.parse_args()
path = "Departures/"
day = "LUN"
if args.dontwait:
	attendre = False
if args.path:
	path = args.path
if args.day:
	day = args.day
if attendre:
	a.waitHour(path, day)
else:
	a.getDepartures(path, day)

		
