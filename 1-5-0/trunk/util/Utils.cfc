<!---
License:
Copyright 2007 GreatBizTools, LLC

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
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.5.0
Updated version: 1.5.0
--->
<cfcomponent 
	displayname="Utils"
	output="false"
	hint="Utility functions for the framework.">
	
	<!---
	PROPERTIES
	--->

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="Utils" output="false"
		hint="Initialization function called by the framework.">
		<cfreturn this />
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="recurseComplexValues" access="public" returntype="any" output="false"
		hint="Recurses through complex values by type.">
		<cfargument name="node" type="any" required="true" />
		
		<cfset var value = "" />
		<cfset var child = "" />
		<cfset var i = "" />
		
		<cfif StructKeyExists(arguments.node.xmlAttributes, "value")>
			<cfset value = arguments.node.xmlAttributes["value"] />
		<cfelse>
			<cfset child = arguments.node.xmlChildren[1] />
			<cfif child.xmlName EQ "value">
				<cfset value = child.xmlText />
			<cfelseif child.xmlName EQ "struct">
				<cfset value = StructNew() />
				<cfloop from="1" to="#ArrayLen(child.xmlChildren)#" index="i">
					<cfset value[child.xmlChildren[i].xmlAttributes["name"]] = recurseComplexValues(child.xmlChildren[i]) />
				</cfloop>
			<cfelseif child.xmlName EQ "array">
				<cfset value = ArrayNew(1) />
				<cfloop from="1" to="#ArrayLen(child.xmlChildren)#" index="i">			
					<cfset ArrayAppend(value, recurseComplexValues(child.xmlChildren[i])) />
				</cfloop>
			</cfif>
		</cfif>
		
		<cfreturn value />
	</cffunction>

	<cffunction name="listFix" access="public" returntype="string" output="false"
		hint="Fixes a list by replacing null entries.">
		<cfargument name="list" type="string" required="true" />
		<cfargument name="listDelimiter" type="string" required="false" default="," />
		<cfargument name="nullString" type="string" required="false" default="NULL" />
		<!--- Rewritten UDF from cflib.org Author: Steven Van Gemert (svg2@placs.net)   --->
		<cfset var delim = arguments.listDelimiter />
		<cfset var null = arguments.nullString />
		<cfset var special_char_list = "\,+,*,?,.,[,],^,$,(,),{,},|,-" />
		<cfset var esc_special_char_list = "\\,\+,\*,\?,\.,\[,\],\^,\$,\(,\),\{,\},\|,\-" />
		<cfset var i = "" />

		<cfif findNoCase(left(arguments.list, 1), delim)>
			<cfset arguments.list = null & arguments.list />
		</cfif> 
		<cfif findNoCase(right(list,1), delim)>
			<cfset arguments.list = arguments.list & null />
		</cfif>

		<cfset i = len(delim) - 1 />
		
		<cfloop condition="i GTE 1">
			<cfset delim = mid(delim, 1, i) & "_Separator_" & mid(delim, i+1, len(delim) - (i)) />
			<cfset i = i - 1 />
		</cfloop>

		<cfset delim = ReplaceList(delim, special_char_list, esc_special_char_list) />
		<cfset delim = Replace(delim, "_Separator_", "|", "ALL") />

		<cfset arguments.list = rereplace(arguments.list, "(" & delim & ")(" & delim & ")", "\1" & null & "\2", "ALL") />
		<cfset arguments.list = rereplace(arguments.list, "(" & delim & ")(" & delim & ")", "\1" & null & "\2", "ALL") />
  
		<cfreturn arguments.list />
	</cffunction>

</cfcomponent>