<cfset vDia=31>
<cfset vMes=12>
<cfset vAno=2019>
<cfset vData=CreateDate(vAno, vMes, vDia)>
<cfoutput>
#DayOfWeek(vData)# 
</cfoutput>
