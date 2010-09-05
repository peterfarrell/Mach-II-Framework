<cfsilent>
<!---

    Mach-II - A framework for object oriented MVC web applications in CFML
    Copyright (C) 2003-2010 GreatBizTools, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.

	As a special exception, the copyright holders of this library give you
	permission to link this library with independent modules to produce an
	executable, regardless of the license terms of these independent
	modules, and to copy and distribute the resultant executable under
	the terms of your choice, provided that you also meet, for each linked
	independent module, the terms and conditions of the license of that
	module.  An independent module is a module which is not derived from
	or based on this library and communicates with Mach-II solely through
	the public interfaces* (see definition below). If you modify this library,
	but you may extend this exception to your version of the library,
	but you are not obligated to do so. If you do not wish to do so,
	delete this exception statement from your version.


	* An independent module is a module which not derived from or based on
	this library with the exception of independent module components that
	extend certain Mach-II public interfaces (see README for list of public
	interfaces).

$Id$

Created version: 1.0.0
Updated version: 1.1.0

Notes:
--->
	<cfimport prefix="dashboard" taglib="/MachII/dashboard/customtags" />
	<cfimport prefix="view" taglib="/MachII/customtags/view" />
	<cfimport prefix="form" taglib="/MachII/customtags/form" />
	<view:meta type="title" content="Configuration" />
	<cfset copyToScope("${event.baseComponentData},${event.moduleData},${event.baseData}") />
	<cfset variables.moduleOrder = StructKeyArray(variables.moduleData) />
	<cfset ArraySort( variables.moduleOrder , "textnocase", "asc") />
	<cfset applicationInstance = createObject("component", "Application") />

	<view:script event="sys.serveAsset" p:path="@js@handler@config.js">
		<cfoutput>
			myConfigHandler = new ConfigHandler('#BuildUnescapedUrl("config.reloadAllChangedComponents")#', '#BuildUnescapedUrl("config.refreshAllChangedComponents")#');
		</cfoutput>
	</view:script>
</cfsilent>
<cfoutput>

<dashboard:displayMessage />

<h1>Configuration File Status</h1>

<ul class="pageNavTabs">
	<li>
		<a href="#buildUrl("config.reloadBaseApp")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@database_refresh.png")#" width="16" height="16" alt="Reload" />
			&nbsp;Reload All Mach-II Config Files
		</a>
	</li>
<cfif StructKeyExists(variables.baseData, "lastDependencyInjectionEngineReloadDateTime")>
	<li>
		<a href="#buildUrl("config.reloadBaseAppDependencyInjectionEngine")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@database_refresh.png")#" width="16" height="16" alt="Reload" />
			&nbsp;Reload All DI Engine Config Files
		</a>
	</li>
</cfif>
	<li>
		<a href="#buildUrl("config.reloadAllChangedComponents")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@database_refresh.png")#" width="16" height="16" alt="Reload" />
			&nbsp;Reload All Changed Components
		</a>
	</li>
	<li>
		<a href="#BuildUrl("config.index")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@arrow_rotate_clockwise.png")#" width="16" height="16" alt="Flush All" />
			&nbsp;Refresh Stats
		</a>
	</li>
</ul>

<table>
	<tr>
		<th style="width:20%;"><h3>Module</h3></th>
		<th style="width:20%;"><h3>Mach-II</h3></th>
		<th style="width:20%;"><h3>DI Engine</h3></th>
		<th style="width:40%;"><h3>Configuration</h3></th>
	</tr>
	<tr>
		<td>
			<h4>Base</h4>
			<p class="small">
				<a href="#BuildUrlToModule("", variables.baseData.appManager.getPropertyManager().getProperty("defaultEvent"))#">
					<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@link_go.png")#" width="16" height="16" alt="Link" />
					go to default event
				</a>
			</p>
		</td>
		<td>
			<p>
				<a href="#buildUrl("config.reloadBaseApp")#">
				<cfif variables.baseData.shouldReloadConfig>
					<span class="red">
						<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
						&nbsp;reloaded #getProperty("udfs").datetimeDifferenceString(variables.baseData.lastReloadDateTime)# ago
					</span>
				<cfelse>
					<span class="green">
					<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
					&nbsp;OK
					</span>
				</cfif>
				</a>
			</p>
		</td>
	<cfif StructKeyExists(variables.baseData, "lastDependencyInjectionEngineReloadDateTime")>
		<td>
			<p>
				<a href="#buildUrl("config.reloadBaseAppDependencyInjectionEngine")#">
					<cfif variables.baseData.shouldReloadDependencyInjectionEngineConfig>
						<span class="red">
							<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
							&nbsp;reloaded #getProperty("udfs").datetimeDifferenceString(variables.baseData.lastDependencyInjectionEngineReloadDateTime)# ago
						</span>
					<cfelse>
						<span class="green">
							<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
							&nbsp;OK
						</span>
					</cfif>
				</a>
			</p>
		</td>
	<cfelse>
		<td>
			<p>n/a</p>
		</td>
	</cfif>
		<td>
			<table class="small">
				<tr>
					<td style="width:50%;"><h4>Environment Name</h4></td>
					<td style="width:50%;"><p>#getAppManager().getParent().getEnvironmentName()#</p></td>
				</tr>
				<tr>
					<td><h4>Environment Group</h4></td>
					<td><p>#getAppManager().getParent().getEnvironmentGroup()#</p></td>
				</tr>
			</table>
		</td>
	</tr>
<cfloop from="1" to="#ArrayLen(variables.moduleOrder)#" index="i">
	<tr <cfif i MOD 2>class="shade"</cfif>>
		<td>
			<h4>#UCase(Left(variables.moduleOrder[i], 1))##Right(variables.moduleOrder[i], Len(variables.moduleOrder[i]) -1)#</h4>
		<cfif getAppManager().getModuleName() NEQ variables.moduleOrder[i]>
			<p class="small">
				<a href="#BuildUrlToModule(variables.moduleOrder[i], variables.moduleData[variables.moduleOrder[i]].appManager.getPropertyManager().getProperty("defaultEvent"))#">
					<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@link_go.png")#" width="16" height="16" alt="Link" />
					go to default event
				</a>
			</p>
		<cfelse>
			<p>&nbsp;</p>
		</cfif>
		</td>
		<td>
			<p>
				<a href="#buildUrl("config.reloadModule", "moduleName=#variables.moduleOrder[i]#")#">
				<cfif variables.moduleData[variables.moduleOrder[i]].shouldReloadConfig>
					<span class="red">
						<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
						&nbsp;reloaded #getProperty("udfs").datetimeDifferenceString(variables.moduleData[variables.moduleOrder[i]].lastReloadDateTime)# ago
					</span>
				<cfelse>
					<span class="green">
						<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
						&nbsp;OK
					</span>
				</cfif>
				</a>
			</p>
		</td>
	<cfif StructKeyExists(variables.moduleData[variables.moduleOrder[i]], "lastDependencyInjectionEngineReloadDateTime")>
		<td>
			<p>
				<a href="#buildUrl("config.reloadModuleDependencyInjectionEngine", "moduleName=#variables.moduleOrder[i]#")#">
					<cfif variables.moduleData[variables.moduleOrder[i]].shouldReloadDependencyInjectionEngineConfig>
						<span class="red">
							<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@exclamation.png")#" width="16" height="16" alt="Reload" />
							&nbsp;reloaded #getProperty("udfs").datetimeDifferenceString(variables.moduleData[variables.moduleOrder[i]].lastDependencyInjectionEngineReloadDateTime)# ago
						</span>
					<cfelse>
						<span class="green">
						<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@tick.png")#" width="16" height="16" alt="OK" />
						&nbsp;OK
						</span>
					</cfif>
				</a>
			</p>
		</td>
	<cfelse>
		<td>
			<p>n/a</p>
		</td>
	</cfif>
		<td>
			<!--- The _ is important or we get errors --->
			<cfset variables._appManager = getAppManager().getModuleManager().getModule(variables.moduleOrder[i]).getModuleAppManager() />
			<table class="small">
				<tr>
					<td style="width:50%;"><h4>Environment Name</h4></td>
					<td style="width:50%;"><p>#variables._appManager.getEnvironmentName()#</p></td>
				</tr>
				<tr>
					<td><h4>Environment Group</h4></td>
					<td><p>#variables._appManager.getEnvironmentGroup()#</p></td>
				</tr>
			</table>
		</td>
	</tr>
</cfloop>
</table>

<h1>Component Status</h1>
<ul class="pageNavTabs">
	<li>
		<a onclick="myConfigHandler.reloadAllChangedComponents();">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@database_refresh.png")#" width="16" height="16" alt="Reload" />
			&nbsp;Reload All Changed Components
		</a>
	</li>
	<li>
		<form:form actionEvent="">
			Check for Changed Components Every <form:select path="reloadAllChangedComponentsValue" items="0,3,6,9,12,15" checkValue="0" onchange="myConfigHandler.periodicUpdateChangedComponents();" /> Seconds
		</form:form>
	</li>
	<li>
		<a onclick="myConfigHandler.updateChangedComponents();">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@arrow_rotate_clockwise.png")#" width="16" height="16" alt="Flush All" />
			&nbsp;Refresh Stats
		</a>
	</li>
	<cfif IsDefined("applicationInstance.ormenabled") AND applicationInstance.ormenabled EQ true >
 	<li>
		<a href="#buildUrl("config.reloadAllOrmComponents")#">
			<img src="#BuildUrl("sys.serveAsset", "path=@img@icons@database_refresh.png")#" width="16" height="16" alt="Reload ORM Components" />
			&nbsp;Reload ORM Components
		</a>
	</li>
	</cfif>
</ul>

<div id="changedComponents">
	#event.getArg('layout.snip_components')#
</div>

<view:script outputType="inline">
	myConfigHandler.updateChangedComponents();
</view:script>
</cfoutput>