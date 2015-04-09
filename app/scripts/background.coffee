'use strict';

chrome.runtime.onInstalled.addListener (details) ->
  console.log('previousVersion', details.previousVersion)

chrome.browserAction.setBadgeText({text: '+15'})

Stat =
  data: {}
  cur: null

tabChanged = (url) ->
  if Stat.cur
    lst = Stat.data[Stat.cur]
    lst.push(new Date())
  Stat.cur = url
  lst = Stat.data[url] or []
  lst.push(new Date())
  Stat.data[url] = lst

calc = (url)->
  lst = Stat.data[url]
  if not lst
    return 0
  n = Math.floor (lst.length / 2)
  res = 0
  for i in [0..n]
    if lst[2 * i + 1] and lst[2 * i]
      res += lst[2 * i + 1].getTime() - lst[2 * i].getTime()
  hh = Math.floor(res / 3600000)
  mm = Math.floor((res % 3600000) / 60000)
  ss = Math.floor((res % 60000) / 1000)
  return hh + ":" + mm + ":" + ss 

updateBadge = (url)->
  res = calc url
  chrome.browserAction.setBadgeText({text: res})

urlCheck = (url)->
  a = document.createElement 'a'
  a.href = url 
  if a.protocol == 'http' or a.protocol == 'https'
    return true
  else 
    return false


chrome.tabs.onActivated.addListener (activeInfo)->
  console.log "Select #{activeInfo.tabId} "
  Stat.curTabId = activeInfo.tabId
  chrome.tabs.get activeInfo.tabId, (tab) ->
    tabChanged(tab.url) if tab.url
    updateBadge tab.url

chrome.alarms.onAlarm.addListener (alarm)->
  console.log alarm, Stat.curTabId
  if alarm.name == "update"
    if not Stat.curTabId
      return
    chrome.tabs.get Stat.curTabId, (tab)->
      console.log tab
      if not urlCheck teb.url
        return 
      if tab.url
        a = document.createElement 'a'
        a.href = tab.url        
        updateBadge a.hostname

chrome.alarms.create("update", {periodInMinutes: 0.1})
console.log('\'Allo \'Allo! Event Page for Browser Action')
