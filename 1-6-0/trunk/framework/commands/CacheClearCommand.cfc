<!---
License:
Copyright 2008 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
$Id: CacheClearCommand.cfc 422 2007-07-06 05:34:59Z pfarrell $

Created version: 1.6.0
Updated version: 1.6.0

Notes:
--->
<cfcomponent
	displayname="CacheClearCommand"
	extends="MachII.framework.Command"
	output="false"
	hint="A Command for clearing caching.">

	<!---
	PROPERTIES
	--->
	<cfset variables.commandType = "cache-clear" />
	<cfset variables.alias = "" />
	<cfset variables.condition = "" />
	<cfset variables.criteria = "" />
	<cfset variables.cacheName = "" />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="CacheClearCommand" output="false"
		hint="Initializes the command.">
		<cfargument name="cacheName" type="string" required="false" default="" />
		<cfargument name="alias" type="string" required="false" default="" />
		<cfargument name="condition" type="string" required="false" default="" />
		<cfargument name="criteria" type="string" required="false" default="" />

		<cfset setAlias(arguments.alias) />
		<cfset setCondition(arguments.condition) />
		<cfset setCacheName(arguments.cacheName) />
		<cfset setCriteria(arguments.criteria) />

		<cfreturn this />
	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="execute" access="public" returntype="boolean" output="false"
		hint="Executes a caching block.">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		
		<cfset var continue = true />
		<cfset var clearCache = false />
		<cfset var cacheManager = arguments.eventContext.getAppManager().getCacheManager() />
		<!--- <cfset var log = getLog() /> --->
		
		<!--- Make decision on whether or not to clear a cache by alias --->
		<cfif NOT Len(getCondition())>
			<!--- <cfif log.isDebugEnabled()>
				<cfset log.debug("Clearing cache by alias '#getAlias()#' (no condition to evaluate).") />
			</cfif> --->
			<cfset clearCache = true />
		<cfelseif evaluate(getCondition())>
			<!--- <cfif log.isDebugEnabled()>
				<cfset log.debug("Clearing cache by alias '#getAlias()#' (condition '#getCondition()#' evaluated true).") />
			</cfif> --->
			<cfset clearCache = true />
		<cfelse>
			<!--- <cfif log.isDebugEnabled()>
				<cfset log.debug("Cannot clear cache by alias '#getAlias()#' (condition '#getCondition()#' evaluated false).") />
			</cfif> --->
		</cfif>
		
		<cfif clearCache>
			<cfset cacheManager.clearCachesByAlias(getAlias(), arguments.event, getCriteria()) />
		</cfif>
		
		<cfreturn continue />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAlias" access="private" returntype="void" output="false">
		<cfargument name="alias" type="string" required="true" />
		<cfset variables.alias = arguments.alias />
	</cffunction>
	<cffunction name="getAlias" access="private" returntype="string" output="false">
		<cfreturn variables.alias />
	</cffunction>
	
	<cffunction name="setCondition" access="private" returntype="void" output="false">
		<cfargument name="condition" type="string" required="true" />
		<cfset variables.condition = arguments.condition />
	</cffunction>
	<cffunction name="getCondition" access="private" returntype="string" output="false">
		<cfreturn variables.condition />
	</cffunction>

	<cffunction name="setCriteria" access="private" returntype="void" output="false">
		<cfargument name="criteria" type="string" required="true" />
		<cfset variables.criteria = arguments.criteria />
	</cffunction>
	<cffunction name="getCriteria" access="public" returntype="string" output="false">
		<cfreturn variables.criteria />
	</cffunction>
	
	<cffunction name="setCacheName" access="private" returntype="void" output="false">
		<cfargument name="cacheName" type="string" required="true" />
		<cfset variables.cacheName = arguments.cacheName />
	</cffunction>
	<cffunction name="getCacheName" access="public" returntype="string" output="false">
		<cfreturn variables.cacheName />
	</cffunction>

</cfcomponent>