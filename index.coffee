_ = require 'lodash'
colors = require 'irc-colors'
moment = require 'moment'
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
                    if current is null
                        @reply origin, "I don't know what the current map rotation is!"
                        return
                    regularMaps = (colors.bold.lime map.nameEN for map in current.regular.maps).join(', ');
                    rankedMaps = (colors.bold.olive map.nameEN for map in current.ranked.maps).join(', ');
                    rankedMode = colors.bold current.ranked.rulesEN
                    timeHours = moment.duration(current.endTime - now).hours()
                    timeMinutes = moment.duration(current.endTime - now).minutes()
                    if timeHours and timeMinutes
                         timeTillNextRotation = colors.bold "#{moment.duration(timeHours, "hours").humanize()} and #{timeMinutes} minutes"
                    else
                         timeTillNextRotation = if timeHours then colors.bold moment.duration(timeHours, "hours").humanize() else colors.bold moment.duration(timeMinutes, "minutes").humanize()
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
                        if rotation.startTime - now < timeTillNextRotation
                            timeTillNextRotation = now - rotation.startTime
                            next = rotation
                    if next is null
                        @reply origin, "I don't know what the next map rotation is!"
                        return
                    regularMaps = (colors.bold.lime map.nameEN for map in next.regular.maps).join(', ');
                    rankedMaps = (colors.bold.olive map.nameEN for map in next.ranked.maps).join(', ');
                    rankedMode = colors.bold next.ranked.rulesEN
                    timeHours = moment.duration(next.startTime - now).hours()
                    timeMinutes = moment.duration(next.startTime - now).minutes()
                    if timeHours and timeMinutes
                         timeTillNextRotation = colors.bold "#{moment.duration(timeHours, "hours").humanize()} and #{timeMinutes} minutes"
                    else
                         timeTillNextRotation = if timeHours then colors.bold moment.duration(timeHours, "hours").humanize() else colors.bold moment.duration(timeMinutes, "minutes").humanize()
                    @reply origin, "Upcoming Turf War maps are #{regularMaps}. Upcoming #{rankedMode} maps are #{rankedMaps}. Maps will rotate in #{timeTillNextRotation}. Stay fresh!"

                .catch (err) =>
                    console.err err
                    @reply origin "Unable to get splatoon.ink data: #{err.message}"

    SplatoonModule
