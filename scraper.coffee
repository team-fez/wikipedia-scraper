# Get more data about a species (namely link, images, summary) from Wikipedia
# @author Torstein Thune
http = require('http')
fs = require('node-fs')
Wiki = require('wikijs')
species = []
speciesWithData = []

getPageInfo = (thing) ->
	if not thing
		writeFile()
	else
		console.log "\n\n#{thing?.Name} (#{species.length} left)"
		
		thing.wikipediaUrl = ""
		thing.summary = ""
		thing.images = []

		try 
			Wiki.page(thing.Name, (err, page) ->
				unless page?
					console.log ' -> no page'
					speciesWithData.push thing
					getPageInfo(species.shift())
				else
					thing.wikipediaUrl = page?.url or= ""

					page?.summary((err,summary) ->
						thing.summary = summary or= ""
						page?.images((err, images) ->
							thing.images = images or= []
							speciesWithData.push thing
							getPageInfo(species.shift())
							# page?.categories((err, categories) ->
							# 	thing.categories = categories
							# )
							# try
							# 	page?.infobox((err, info) ->
							# 		unless err
							# 			console.log 'info'
							# 			thing.info = info
							# 			speciesWithData.push(thing)
							# 			if species.length > 0
							# 				getPageInfo(species.shift())
							# 	)
							# catch e
						)
					)
			)
		catch e 
			console.log ' -> error'
			speciesWithData.push thing
			getPageInfo(species.shift())


writeFile = () ->
	fs.writeFile('wikiscrape.json', JSON.stringify(speciesWithData, false, '\t'), (err) ->
		console.log 'we are done =)' unless err
	)


fs.readFile('species.json', 'utf-8', (err, data) =>
	species = JSON.parse(data)

	console.log "We have #{species.length} species"
	speciesWithData = []

	getPageInfo(species.shift())
		
)

	