_ = require 'lodash'
colors = require 'irc-colors'
human = require 'human-time'
got = require 'got'
module.exports = (Module) ->
    class SplatoonModule extends Module
        shortName: 'Splatoon'
        helpText:
            default: 'Gets the current and next maps in rotation for Splatoon. Use !splatoon for current maps and time till next rotation, and !splatoon-next for upcoming maps.'
            "splatoon-next": 'Gets the next maps in rotation for Splatoon.'
        usage:
            default: 'splatoon'
            "splatoon-next": 'splatoon-next'

        constructor: (moduleManager) ->
            super

            @addRoute 'splatoon', (origin, route) =>
                got 'http://splatoon.ink/schedule.json'
                .then (res) =>
                    json = JSON.parse res.body
                    now = (new Date()).getTime()
                    current = null
                    timeTillNextRotation = Number.MAX_VALUE
                    for rotation in json.schedule
                        current = rotation if rotation.startTime < now < rotation.endTime
                        break
                    regularMaps = (colors.bold.lime map.nameEN for map in current.regular.maps).join(', ');
                    rankedMaps = (colors.bold.olive map.nameEN for map in current.ranked.maps).join(', ');
                    rankedMode = colors.bold current.ranked.rulesEN
                    timeTillNextRotation = colors.bold human (now - current.endTime) / 1000
                    @reply origin, "Current Turf War maps are #{regularMaps}. Current #{rankedMode} maps are #{rankedMaps}. Maps rotate in #{timeTillNextRotation}. Stay fresh!"

                .catch (err) =>
                    console.err err
                    @reply origin "Unable to get splatoon.ink data: #{err.message}"

            @addRoute 'splatoon-next', (origin, route) =>
                got 'http://splatoon.ink/schedule.json'
                .then (res) =>
                    json = JSON.parse res.body
                    now = (new Date()).getTime()
                    next = null
                    timeTillNextRotation = Number.MAX_VALUE
                    for rotation in json.schedule
                        if(now - rotation.startTime < timeTillNextRotation)
                            timeTillNextRotation = now - rotation.startTime
                            next = rotation
                    regularMaps = (colors.bold.lime map.nameEN for map in next.regular.maps).join(', ');
                    rankedMaps = (colors.bold.olive map.nameEN for map in next.ranked.maps).join(', ');
                    rankedMode = colors.bold next.ranked.rulesEN
                    timeTillNextRotation = colors.bold human (now - next.startTime) / 1000
                    @reply origin, "Upcoming Turf War maps are #{regularMaps}. Upcoming #{rankedMode} maps are #{rankedMaps}. Maps will rotate in #{timeTillNextRotation}. Stay fresh!"

                .catch (err) =>
                    console.err err
                    @reply origin "Unable to get splatoon.ink data: #{err.message}"

    SplatoonModule
