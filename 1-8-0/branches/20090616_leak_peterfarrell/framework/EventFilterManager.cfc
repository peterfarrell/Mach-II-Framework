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
$Id$

Created version: 1.0.0
Updated version: 1.8.0

Notes:
--->
<cfcomponent 
	displayname="EventFilterManager"
	output="false"
	hint="Manages registered EventFilters for the framework.">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.appManager = "" />
	<cfset variables.parentFilterManager = "" />
	<cfset variables.filterProxies = StructNew() />
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="EventFilterManager" output="false"
		hint="Initialization function called by the framework.">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		
		<cfset setAppManager(arguments.appManager) />
		
		<cfif getAppManager().inModule()>
			<cfset setParent(getAppManager().getParent().getFilterManager()) />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="loadXml" access="public" returntype="void" output="false"
		hint="Loads xml for the manager.">
		<cfargument name="configXML" type="string" required="true" />
		<cfargument name="override" type="boolean" required="false" default="false" />
					
		<cfset var filterNodes = ArrayNew(1) />
		<cfset var filterParams = "" />
		<cfset var filterName = "" />
		<cfset var filterType = "" />
		<cfset var filter = "" />
		
		<cfset var paramNodes = ArrayNew(1) />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />

		<cfset var utils = getAppManager().getUtils() />
		<cfset var baseProxy = "" />
		<cfset var hasParent = IsObject(getParent()) />
		<cfset var mapping = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />

		<!--- Search for EventFilters --->
		<cfif NOT arguments.override>
			<cfset filterNodes = XMLSearch(arguments.configXML, "mach-ii/event-filters/event-filter") />
		<cfelse>
			<cfset filterNodes = XMLSearch(arguments.configXML, ".//event-filters/event-filter") />
		</cfif>
		
		<!--- Setup up each EventFilter --->
		<cfloop from="1" to="#ArrayLen(filterNodes)#" index="i">
			<cfset filterName = filterNodes[i].xmlAttributes["name"] />
			
			<!--- Override XML for Modules --->
			<cfif hasParent AND arguments.override AND StructKeyExists(filterNodes[i].xmlAttributes, "overrideAction")>
				<cfif filterNodes[i].xmlAttributes["overrideAction"] EQ "useParent">
					<cfset removeFilter(filterName) />
				<cfelseif filterNodes[i].xmlAttributes["overrideAction"] EQ "addFromParent">
					<!--- Check for a mapping --->
					<cfif StructKeyExists(filterNodes[i].xmlAttributes, "mapping")>
						<cfset mapping = filterNodes[i].xmlAttributes["mapping"] />
					<cfelse>
						<cfset mapping = filterName />
					</cfif>
					
					<!--- Check if parent has event handler with the mapping name --->
					<cfif NOT getParent().isFilterDefined(mapping)>
						<cfthrow type="MachII.framework.overrideFilterNotDefined"
							message="An filter named '#mapping#' cannot be found in the parent event filter manager for the override named '#filterName#' in module '#getAppManager().getModuleName()#'." />
					</cfif>
					
					<cfset addFilter(filterName, getParent().getFilter(mapping), arguments.override) />
				</cfif>
			<!--- General XML setup --->
			<cfelse>
				<cfset filterType = filterNodes[i].xmlAttributes["type"] />
			
				<!--- Set the EventFilter's parameters. --->
				<cfset filterParams = StructNew() />
				
				<!--- For each filter, parse all the parameters --->
				<cfif StructKeyExists(filterNodes[i], "parameters")>
					<cfset paramNodes = filterNodes[i].parameters.xmlChildren />
					<cfloop from="1" to="#ArrayLen(paramNodes)#" index="j">
						<cfset paramName = paramNodes[j].xmlAttributes["name"] />
						<cftry>
							<cfset paramValue = utils.recurseComplexValues(paramNodes[j]) />
							<cfcatch type="any">
								<cfthrow type="MachII.framework.InvalidParameterXml"
									message="Xml parsing error for the parameter named '#paramName#' for event-filter '#filterName#' in module '#getAppManager().getModuleName()#'." />
							</cfcatch>
						</cftry>
						<cfset filterParams[paramName] = paramValue />
					</cfloop>
				</cfif>
				
				<cftry>
					<!--- Do not method chain the init() on the instantiation
						or objects that have their init() overridden will
						cause the variable the object is assigned to will 
						be deleted if init() returns void --->
					<cfset filter = CreateObject("component", filterType) />
					<cfset filter.init(getAppManager(), filterParams) />

					<cfcatch type="expression">
						<cfthrow type="MachII.framework.EventFilterSyntaxException"
							message="Mach-II could not register an event-filter with type of '#filterType#' for the event-filter named '#filterName#' in module named '#getAppManager().getModuleName()#'. #cfcatch.message#"
							detail="#cfcatch.detail#" />
					</cfcatch>	
					<cfcatch type="any">
						<cfif StructKeyExists(cfcatch, "missingFileName")>
							<cfthrow type="MachII.framework.CannotFindEventFilter"
								message="Cannot find a CFC with the type of '#filterType#' for the event-filter named '#filterName#' in module named '#getAppManager().getModuleName()#'."
								detail="Please check that a event-filter exists and that there is not a misconfiguration in the XML configuration file.">
						<cfelse>
							<cfrethrow />
						</cfif>
					</cfcatch>
				</cftry>

				<cfset baseProxy = CreateObject("component",  "MachII.framework.BaseProxy").init(filter, filterType, filterParams) />
				<cfset filter.setProxy(baseProxy) />
				
				<cfset addFilter(filterName, filter, arguments.override) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="configure" access="public" returntype="void"
		hint="Configures each of the registered EventFilters.">
		
		<cfset var appManager = getAppManager() />
		<cfset var aFilter = 0 />
		<cfset var i = 0 />
		
		<cfloop collection="#variables.filterProxies#" item="i">
			<cfset aFilter = variables.filterProxies[i].getObject() />
			<cfset appManager.onObjectReload(aFilter) />
			<cfset aFilter.configure() />
		</cfloop>
	</cffunction>

	<cffunction name="deconfigure" access="public" returntype="void"
		hint="Performs deconfiguration logic.">
		
		<cfset var aFilter = 0 />
		<cfset var i = 0 />
		
		<cfloop collection="#variables.filterProxies#" item="i">
			<cfset aFilter = variables.filterProxies[i].getObject() />
			<cfset aFilter.deconfigure() />
		</cfloop>
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="addFilter" access="public" returntype="void" output="false"
		hint="Registers an EventFilter by name.">
		<cfargument name="filterName" type="string" required="true" />
		<cfargument name="filter" type="MachII.framework.EventFilter" required="true" />
		<cfargument name="overrideCheck" type="boolean" required="false" default="false" />
		
		<cfif NOT arguments.overrideCheck AND isFilterDefined(arguments.filterName)>
			<cfthrow type="MachII.framework.FilterAlreadyDefined"
				message="An EventFilter with name '#arguments.filterName#' is already registered." />
		<cfelse>
			<cfset variables.filterProxies[arguments.filterName] = arguments.filter.getProxy() />
		</cfif>
	</cffunction>
	
	<cffunction name="getFilter" access="public" returntype="MachII.framework.EventFilter" output="false">
		<cfargument name="filterName" type="string" required="true" />
		
		<cfif isFilterDefined(arguments.filterName)>
			<cfreturn variables.filterProxies[arguments.filterName].getObject() />
		<cfelseif IsObject(getParent()) AND getParent().isFilterDefined(arguments.filterName)>
			<cfreturn getParent().getFilter(arguments.filterName) />
		<cfelse>
			<cfthrow type="MachII.framework.FilterNotDefined" 
				message="Filter with name '#arguments.filterName#' is not defined." />
		</cfif>
	</cffunction>
	
	<cffunction name="removeFilter" access="public" returntype="void" output="false"
		hint="Removes a filter. Does NOT remove from a parent.">
		<cfargument name="filterName" type="string" required="true" />
		<cfset StructDelete(variables.filterProxies, arguments.filterName, false) />
	</cffunction>
	
	<cffunction name="isFilterDefined" access="public" returntype="boolean" output="false"
		hint="Checks if a filter is defined in this event filter manager. Does NOT check the parent.">
		<cfargument name="filterName" type="string" required="true" />
		<cfreturn StructKeyExists(variables.filterProxies, arguments.filterName) />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS - UTILS
	--->
	<cffunction name="getFilterNames" access="public" returntype="array" output="false"
		hint="Returns an array of filter names.">
		<cfreturn StructKeyArray(variables.filterProxies) />
	</cffunction>
	
	<cffunction name="reloadFilter" access="public" returntype="void" output="false"
		hint="Reloads an event-filter.">
		<cfargument name="filterName" type="string" required="true" />
		
		<cfset var newFilter = "" />
		<cfset var currentFilter = getFilter(arguments.filterName) />
		<cfset var baseProxy = currentFilter.getProxy() />
		
		<!--- Setup the Filter --->
		<cftry>
			<!--- Do not method chain the init() on the instantiation
				or objects that have their init() overridden will
				cause the variable the object is assigned to will 
				be deleted if init() returns void --->
			<cfset newFilter = CreateObject("component", baseProxy.getType()) />
			<cfset newFilter.init(getAppManager(), baseProxy.getOriginalParameters()) />

			<cfcatch type="expression">
				<cfthrow type="MachII.framework.EventFilterSyntaxException"
					message="Mach-II could not register an event-filter with type of '#baseProxy.getType()#' for the event-filter named '#arguments.filterName#' in module named '#getAppManager().getModuleName()#'. #cfcatch.message#"
					detail="#cfcatch.detail#" />
			</cfcatch>	
			<cfcatch type="any">
				<cfif StructKeyExists(cfcatch, "missingFileName")>
					<cfthrow type="MachII.framework.CannotFindEventFilter"
						message="Cannot find a CFC with the type of '#baseProxy.getType()#' for the event-filter named '#arguments.filterName#' in module named '#getAppManager().getModuleName()#'."
						detail="Please check that a event-filter exists and that there is not a misconfiguration in the XML configuration file.">
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<!--- Run deconfigure in the current Filter 
			which must take place before configure is
			run in the new Filter --->
		<cfset currentFilter.deconfigure() />
		
		<!--- Continue setup on the Filter --->
		<cfset baseProxy.setObject(newFilter) />
		<cfset newFilter.setProxy(baseProxy) />
		
		<!--- Configure the Filter --->
		<cfset getAppManager().onObjectReload(newFilter) />
		<cfset newFilter.configure() />

		<!--- Add the Filter to the manager --->
		<cfset addFilter(arguments.filterName, newFilter, true) />
	</cffunction>
	
	<!---
	ACCESSORS
	--->
	<cffunction name="setAppManager" access="public" returntype="void" output="false">
		<cfargument name="appManager" type="MachII.framework.AppManager" required="true" />
		<cfset variables.appManager = arguments.appManager />
	</cffunction>
	<cffunction name="getAppManager" access="public" returntype="MachII.framework.AppManager" output="false">
		<cfreturn variables.appManager />
	</cffunction>
	<cffunction name="setParent" access="public" returntype="void" output="false"
		hint="Returns the parent FilterManager instance this FilterManager belongs to.">
		<cfargument name="parentFilterManager" type="MachII.framework.EventFilterManager" required="true" />
		<cfset variables.parentFilterManager = arguments.parentFilterManager />
	</cffunction>
	<cffunction name="getParent" access="public" returntype="any" output="false"
		hint="Sets the parent FilterManager instance this FilterManager belongs to. It will return empty string if no parent is defined.">
		<cfreturn variables.parentFilterManager />
	</cffunction>
	
</cfcomponent>