<!--- 
  <cfdump  var="#url#">

 <cfoutput>
 #dtlimit#
 </cfoutput>
 --->
<cfprocessingdirective pageEncoding ="utf-8"> 
<cfsetting requesttimeout="15000"> 
<cfoutput>
<!---
	<cfset dtlimit = year(now()) & "/01/31">
	dtlimit:#dtlimit#  se: #se#   <br>
--->

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(Trim(qUsuario.Usu_GrupoAcesso))>

<cfif grpacesso neq 'GESTORMASTER'>
	<cfset aux_mes = month(dtlimit)>
	<cfset aux_ano = year(dtlimit)>
	<cfif aux_mes is 1>
		<cfset dtlimit = (aux_ano - 1) & "/12/31">
	<cfelseif aux_mes is 2>
		<cfset dtlimit = aux_ano  & "/01/31">		
	<cfelseif aux_mes is 3>  
		<cfif int(aux_ano) mod 4 is 0>
			<cfset dtlimit = aux_ano & "/02/29">
		<cfelse>
			<cfset dtlimit = aux_ano & "/02/28">
		</cfif>
	<cfelseif aux_mes is 4>
		<cfset dtlimit = aux_ano & "/03/31">
	<cfelseif aux_mes is 5>
		<cfset dtlimit = aux_ano & "/04/30">		
	<cfelseif aux_mes is 6>
		<cfset dtlimit = aux_ano & "/05/31">		
	<cfelseif aux_mes is 7>
		<cfset dtlimit = aux_ano & "/06/30">					   
	<cfelseif aux_mes is 8>
		<cfset dtlimit = aux_ano & "/07/31">					   
	<cfelseif aux_mes is 9>
		<cfset dtlimit = aux_ano & "/08/31">					   
	<cfelseif aux_mes is 10>
		<cfset dtlimit = aux_ano & "/09/30">					   
	<cfelseif aux_mes is 11>
		<cfset dtlimit = aux_ano & "/10/31">	
	<cfelseif aux_mes is 12>	
		<cfset dtlimit = aux_ano & "/11/30">	   				   			   
	</cfif>
</cfif>

	<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		SELECT Dir_codigo, Dir_Sigla, Dir_Descricao FROM Diretoria WHERE Dir_codigo = '#se#'
	</cfquery>
	<cfset auxfilta = #qAcesso.Dir_Descricao#>
	<cfset auxfiltb = 'SE/' & #qAcesso.Dir_Sigla#>

	<cfinclude template="cabecalho.cfm">
	<html>
	<head>
	<title>Sistema Nacional de Controle Interno</title>
	<link href="CSS.css" rel="stylesheet" type="text/css">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link href="css.css" rel="stylesheet" type="text/css">
	<script language="javascript">
	//=============================

	function listar(a,b,c,d,e){
		document.formx.lis_se.value=a;
		document.formx.lis_grpace.value=b;
		document.formx.lis_mes.value=c;
		document.formx.lis_soluc.value=d;
		document.formx.lis_outros.value=e;
		document.formx.submit(); 
	}
	</script>

	</head>
	<body>
	<form action="" method="post" target="_blank" name="form1">
	<cfset anoexerc = year(dtlimit)>
	<cfset totsolmes = 0>
	<cfset totpendtratmes = 0>

	<cfset totsoljan = 0>
	<cfset totsolfev = 0>
	<cfset totsolmar = 0>
	<cfset totsolabr = 0>
	<cfset totsolmai = 0>
	<cfset totsoljun = 0>
	<cfset totsoljul = 0>
	<cfset totsolago = 0>
	<cfset totsolset = 0>
	<cfset totsolout = 0>
	<cfset totsolnov = 0>
	<cfset totsoldez = 0>

	<cfset totpendtratjan = 0>
	<cfset totpendtratfev = 0>
	<cfset totpendtratmar = 0>
	<cfset totpendtratabr = 0>
	<cfset totpendtratmai = 0>
	<cfset totpendtratjun = 0>
	<cfset totpendtratjul = 0>
	<cfset totpendtratago = 0>
	<cfset totpendtratset = 0>
	<cfset totpendtratout = 0>
	<cfset totpendtratnov = 0>
	<cfset totpendtratdez = 0>

	<cfset totmesunsol = 0>	
	<cfset totmesgesol = 0>	
	<cfset totmessbsol = 0>	
	<cfset totmessusol = 0>		
	
	<cfquery name="rsTodos" datasource="#dsn_inspecao#">
		SELECT Andt_RespAnt,Andt_Unid as UNID, Andt_Insp as INSP, Andt_Grp as Grupo, Andt_Item as Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_Mes, Andt_Prazo
		FROM Andamento_Temp
		WHERE (Andt_AnoExerc = '#anoexerc#') AND  (Andt_Mes <= #month(dtlimit)#) AND (Andt_TipoRel = 2) and (Andt_CodSE =  '#se#')
		order by Andt_Mes
	</cfquery> 
	<cfset startTime = CreateTime(0,0,0)> 
	<cfset endTime = CreateTime(0,0,50)> 
	<cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
	</cfloop>	
	<cfset aux_mes = month(dtlimit)>

	<!--- quant. (3-SOL) no mês --->
	<!--- Unidades --->	
	<cfquery dbtype="query" name="rsExisteUN">
		SELECT Andt_RespAnt 
		FROM  rsTodos
		where (Andt_RespAnt in (1,2,15,14,11) or Andt_Resp in (2,15)) and (Andt_Mes <= #month(dtlimit)#)
	</cfquery>
	<cfset totExisteUN = rsExisteUN.recordcount>

	<!--- Áreas --->
	<cfquery dbtype="query" name="rsExisteGE">
		SELECT Andt_RespAnt 
		FROM  rsTodos
		where Andt_RespAnt in (6,5,19) and (Andt_Mes <= #month(dtlimit)#)
	</cfquery>
	<cfset totExisteGE = rsExisteGE.recordcount>

	<!--- Subordinadores --->
	<cfquery dbtype="query" name="rsExisteSB">
		SELECT Andt_RespAnt 
		FROM  rsTodos
		where Andt_RespAnt in (4,7,16) and (Andt_Mes <= #month(dtlimit)#)
	</cfquery>
	<cfset totExisteSB = rsExisteSB.recordcount>
	
	<!--- Superintendencia --->
	<cfquery dbtype="query" name="rsExisteSU">
		SELECT Andt_RespAnt 
		FROM  rsTodos
		where Andt_RespAnt in (8,22,23) and (Andt_Mes <= #month(dtlimit)#)
	</cfquery>
	<cfset totExisteSU = rsExisteSU.recordcount>
	
	<!--- exibicao em tela 
	<cfquery name="rsBaseB" datasource="#dsn_inspecao#">
		SELECT Andt_Unid as UNID, Andt_Insp as INSP, Andt_Grp as Grupo, Andt_Item as Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_Mes, Andt_Prazo
		FROM Andamento_Temp 
		WHERE (Andt_AnoExerc = '#anoexerc#') AND  (Andt_Mes <= #month(dtlimit)#) AND (Andt_Resp <> 3) and (Andt_TipoRel = 2) and (Andt_CodSE =  '#se#')
		order by Andt_Mes
	</cfquery>
	--->
	<cfset auxtit = "SE: " & #qAcesso.Dir_codigo# & "-" & #qAcesso.Dir_Sigla#>
	<cfset MesAC = 'Resultado do Período'>  
	<br>
  	<table width="39%" border="1" align="center" cellpadding="0" cellspacing="0">
      <tr>
        <td colspan="17"><div align="center" class="titulo1"><strong>#auxfilta#</strong></div></td>
      </tr>

	        <tr>
	          <td colspan="17">&nbsp;</td>
      </tr>
	        <tr>
	          <td colspan="17"><div align="center">
	            <p><span class="titulo1"><strong>Solução de Não Conformidades (SLNC)</strong></span></p>
	            </div></td>
      </tr>
	  	        <tr>
	          <td colspan="17">&nbsp;</td>
      </tr>
	<!--- UNIDADES --->		
	<cfif totExisteUN neq 0>	
		<cfset totparcialunsol = 0>
		<cfset totparcialunpendtrat = 0>	     
		<tr class="exibir">
			<td colspan="17" class="titulos"><div align="center">Unidades</div></td>
		</tr>
		<tr class="exibir">
			<td width="10%"><div align="center"><strong>Mês</strong></div></td>
			<td width="30%"><div align="center"><strong>Quantidade (Solucionados)</strong></div></td> 
			<td width="30%"><div align="center"><strong>Outras</strong></div></td>
			<td width="16%"><div align="center"><strong>Total (*)</strong></div></td>
			<td width="10%"><div align="center">%</div></td>
			<td class="exibir">&nbsp;</td>
		</tr>	
		<cfset aux_mes_un = 1>
		<cfloop condition="aux_mes_un lte month(dtlimit)">
			<!--- OBTER QTD. SOLUCIONADOS --->     
			<cfquery dbtype="query" name="rstotsolmes">
				SELECT Andt_RespAnt 
				FROM  rsTodos
				where Andt_RespAnt in (1,2,15,14,11) and Andt_Mes = #aux_mes_un# AND (Andt_Resp=3)
			</cfquery>	
			<!--- Quant. UNIDADES SOLUCIONADO --->
			<cfset totsolmes = rstotsolmes.recordcount>

			<!--- Obter PENDENTES + TRATAMENTOS DO MES  --->     
			<cfquery dbtype="query" name="rstotpendtratmes">
				SELECT Andt_Resp 
				FROM  rsTodos
				where Andt_Resp in (2,15) and Andt_Mes = #aux_mes_un# 
			</cfquery>				
			<cfset totpendtratmes = rstotpendtratmes.recordcount>
<!---
<cfoutput>
aux_mes_un:#aux_mes_un# totpendtratmes: #totpendtratmes#<br>
</cfoutput>
--->
			<cfif aux_mes_un is 1>
				<cfset mestext = 'JAN'>
				<cfset totsoljan = totsoljan + totsolmes>
				<cfset totpendtratjan = totpendtratjan + totpendtratmes>
			<cfelseif aux_mes_un is 2>  
				<cfset mestext = 'FEV'>   
				<cfset totsolfev = totsolfev + totsolmes>
				<cfset totpendtratfev = totpendtratfev + totpendtratmes>                             
			<cfelseif aux_mes_un is 3>
				<cfset mestext = 'MAR'>   
				<cfset totsolmar = totsolmar + totsolmes>
				<cfset totpendtratmar = totpendtratmar + totpendtratmes>                                  
			<cfelseif aux_mes_un is 4>
				<cfset mestext = 'ABR'>	                	
				<cfset totsolabr = totsolabr + totsolmes>
				<cfset totpendtratabr = totpendtratabr + totpendtratmes>                 
			<cfelseif aux_mes_un is 5>
				<cfset mestext = 'MAI'>	      
				<cfset totsolmai = totsolmai + totsolmes>
				<cfset totpendtratmai = totpendtratmai + totpendtratmes>                               	
			<cfelseif aux_mes_un is 6>
				<cfset mestext = 'JUN'>	                    
				<cfset totsoljun = totsoljun + totsolmes>
				<cfset totpendtratjun = totpendtratjun + totpendtratmes>                   			   
			<cfelseif aux_mes_un is 7>
				<cfset mestext = 'JUL'>		                  
				<cfset totsoljul = totsoljul + totsolmes>
				<cfset totpendtratjul = totpendtratjul + totpendtratmes>                     		   
			<cfelseif aux_mes_un is 8>
				<cfset mestext = 'AGO'>			               	
				<cfset totsolago = totsolago + totsolmes>
				<cfset totpendtratago = totpendtratago + totpendtratmes>                       
			<cfelseif aux_mes_un is 9>
				<cfset mestext = 'SET'>			                
				<cfset totsolset = totsolset + totsolmes>
				<cfset totpendtratset = totpendtratset + totpendtratmes>                        	   
			<cfelseif aux_mes_un is 10>
				<cfset mestext = 'OUT'>                 
				<cfset totsolout = totsolout + totsolmes>
				<cfset totpendtratout = totpendtratout + totpendtratmes>                    
			<cfelseif aux_mes_un is 11>	
				<cfset mestext = 'NOV'>	   		              
				<cfset totsolnov = totsolnov + totsolmes>
				<cfset totpendtratnov = totpendtratnov + totpendtratmes>                       		   
			<cfelse>
				<cfset mestext = 'DEZ'>		
				<cfset totsoldez = totsoldez + totsolmes>
				<cfset totpendtratdez = totpendtratdez + totpendtratmes>                   	                   	   
			</cfif> 
			<cfset totparcialunsol = totparcialunsol + totsolmes>
			<cfset totparcialunpendtrat = totparcialunpendtrat + totpendtratmes>
		
			<tr class="exibir">
				<td><div align="center"><strong>#mestext#</strong></div></td>
				<td><div align="center"><strong>#totsolmes#</strong></div></td>
				<cfset habunidsn = ''>
				<cfif mestext eq 0>
					<cfset habunidsn = 'disabled'>
				</cfif>
				<cfif totsolmes neq 0>
					<cfset Per = NumberFormat(totsolmes/(totsolmes + totpendtratmes)* 100,999.0)>
				<cfelse>
					<cfset Per = 0>
				</cfif>

				<td><div align="center"><strong>#totpendtratmes#</strong></div></td>
				<td><div align="center"><strong>#(totsolmes + totpendtratmes)#</strong></div></td>
				<td><div align="center">#NumberFormat(Per,999.0)#</div></td> 	
				<td width="19%" class="exibir"><div align="center"><button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un','#aux_mes_un#',<cfoutput>#totsolmes#</cfoutput>,<cfoutput>#totpendtratmes#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button></div></td>	
			</tr>
                <cfset aux_mes_un = aux_mes_un + 1>
        </cfloop>		
	
		<tr class="exibir">
			<td colspan="17"><hr></td>
		</tr>

		<cfset totparcialunsolpendtrat = (totparcialunsol + totparcialunpendtrat)>
		<cfset pendtrat=(totparcialunsolpendtrat - totparcialunsol)>
		<cfset Acum_Per_UN = 0> 
		<cfif totparcialunsol gt 0>
			<cfset Acum_Per_UN = NumberFormat(((totparcialunsol/totparcialunsolpendtrat) * 100),999.0)>
		</cfif>		
		
		<tr class="tituloC">
			<td class="red_titulo"><div align="center">#MesAC#</div></td>
			<td class="red_titulo"><div align="center"><strong>#totparcialunsol#</strong></div></td>
			<td class="red_titulo"><div align="center">#pendtrat#</div></td>
			<td class="red_titulo"><div align="center">#totparcialunsolpendtrat#</div></td>
			<td class="red_titulo"><div align="center"><strong>#Acum_Per_UN#</strong></div></td>
			<td class="red_titulo">
				<div align="center"><button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'un',0,<cfoutput>#totparcialunsol#</cfoutput>,<cfoutput>#pendtrat#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar(Todos)</button></div></td>
		</tr>	
	</cfif>
<!--- AREAS --->	
<cfif totExisteGE neq 0>	
		<cfset totparcialgesol = 0>
		<cfset totparcialgependtrat = 0>   
		<tr class="exibir">
			<td colspan="17" class="titulos"><div align="center">Gerências Regionais e Áreas de Suporte</div></td>
		</tr>
		<tr class="exibir">
			<td width="10%"><div align="center"><strong>Mês</strong></div></td>
			<td width="30%"><div align="center"><strong>Quantidade (Solucionados)</strong></div></td> 
			<td width="30%"><div align="center"><strong>Outras</strong></div></td>
			<td width="16%"><div align="center"><strong>Total (*)</strong></div></td>
			<td width="10%"><div align="center">%</div></td>
			<td class="exibir">&nbsp;</td>
		</tr>		
		<cfset aux_mes_ge = 1>
		<cfloop condition="aux_mes_ge lte month(dtlimit)">
			<!--- OBTER QTD. SOLUCIONADOS --->     
			<cfquery dbtype="query" name="rstotsolmes">
				SELECT Andt_RespAnt 
				FROM  rsTodos
				where Andt_RespAnt in (6,5,19) and Andt_Mes = #aux_mes_ge# AND (Andt_Resp=3)
			</cfquery>	
			<!--- Quant. UNIDADES SOLUCIONADO --->
			<cfset totsolmes = rstotsolmes.recordcount>

			<!--- Obter PENDENTES + TRATAMENTOS DO MES  --->     
			<cfquery dbtype="query" name="rstotpendtratmes">
				SELECT Andt_Resp 
				FROM  rsTodos
				where Andt_Resp in (5,19) and Andt_Mes = #aux_mes_ge#
			</cfquery>				
			<cfset totpendtratmes = rstotpendtratmes.recordcount>

			<cfif aux_mes_ge is 1>
				<cfset mestext = 'JAN'>
				<cfset totsoljan = totsoljan + totsolmes>
				<cfset totpendtratjan = totpendtratjan + totpendtratmes>
			<cfelseif aux_mes_ge is 2>  
				<cfset mestext = 'FEV'>   
				<cfset totsolfev = totsolfev + totsolmes>
				<cfset totpendtratfev = totpendtratfev + totpendtratmes>                             
			<cfelseif aux_mes_ge is 3>
				<cfset mestext = 'MAR'>   
				<cfset totsolmar = totsolmar + totsolmes>
				<cfset totpendtratmar = totpendtratmar + totpendtratmes>                                  
			<cfelseif aux_mes_ge is 4>
				<cfset mestext = 'ABR'>	                	
				<cfset totsolabr = totsolabr + totsolmes>
				<cfset totpendtratabr = totpendtratabr + totpendtratmes>                 
			<cfelseif aux_mes_ge is 5>
				<cfset mestext = 'MAI'>	      
				<cfset totsolmai = totsolmai + totsolmes>
				<cfset totpendtratmai = totpendtratmai + totpendtratmes>                               	
			<cfelseif aux_mes_ge is 6>
				<cfset mestext = 'JUN'>	                    
				<cfset totsoljun = totsoljun + totsolmes>
				<cfset totpendtratjun = totpendtratjun + totpendtratmes>                   			   
			<cfelseif aux_mes_ge is 7>
				<cfset mestext = 'JUL'>		                  
				<cfset totsoljul = totsoljul + totsolmes>
				<cfset totpendtratjul = totpendtratjul + totpendtratmes>                     		   
			<cfelseif aux_mes_ge is 8>
				<cfset mestext = 'AGO'>			               	
				<cfset totsolago = totsolago + totsolmes>
				<cfset totpendtratago = totpendtratago + totpendtratmes>                       
			<cfelseif aux_mes_ge is 9>
				<cfset mestext = 'SET'>			                
				<cfset totsolset = totsolset + totsolmes>
				<cfset totpendtratset = totpendtratset + totpendtratmes>                        	   
			<cfelseif aux_mes_ge is 10>
				<cfset mestext = 'OUT'>                 
				<cfset totsolout = totsolout + totsolmes>
				<cfset totpendtratout = totpendtratout + totpendtratmes>                    
			<cfelseif aux_mes_ge is 11>	
				<cfset mestext = 'NOV'>	   		              
				<cfset totsolnov = totsolnov + totsolmes>
				<cfset totpendtratnov = totpendtratnov + totpendtratmes>                       		   
			<cfelse>
				<cfset mestext = 'DEZ'>		
				<cfset totsoldez = totsoldez + totsolmes>
				<cfset totpendtratdez = totpendtratdez + totpendtratmes>                   	                   	   
			</cfif>
			<cfset totparcialgesol = totparcialgesol + totsolmes>
			<cfset totparcialgependtrat = totparcialgependtrat + totpendtratmes>
			<tr class="exibir">
				<td><div align="center"><strong>#mestext#</strong></div></td>
				<td><div align="center"><strong>#totsolmes#</strong></div></td>
				<cfset habunidsn = ''>
				<cfif mestext eq 0>
					<cfset habunidsn = 'disabled'>
				</cfif>
				<cfif totsolmes neq 0>
					<cfset Per = NumberFormat(totsolmes/(totsolmes + totpendtratmes)* 100,999.0)>
				<cfelse>
					<cfset Per = 0>
				</cfif>
				<td><div align="center"><strong>#totpendtratmes#</strong></div></td>
				<td><div align="center"><strong>#(totsolmes + totpendtratmes)#</strong></div></td>
				<td><div align="center">#NumberFormat(Per,999.0)#</div></td> 	
				<td width="19%" class="exibir"><div align="center"><button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge','#aux_mes_ge#',<cfoutput>#totsolmes#</cfoutput>,<cfoutput>#totpendtratmes#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button></div></td>	
			</tr>
                <cfset aux_mes_ge = aux_mes_ge + 1>
        </cfloop>		
		<tr class="exibir">
			<td colspan="17"><hr></td>
		</tr>

		<cfset totparcialgesolpendtrat = (totparcialgesol + totparcialgependtrat)>
		<cfset pendtrat=(totparcialgesolpendtrat - totparcialgesol)>
		<cfset Acum_Per_GE = 0> 
		<cfif totparcialgesol gt 0>
			<cfset Acum_Per_GE = NumberFormat(((totparcialgesol/totparcialgesolpendtrat) * 100),999.0)>
		</cfif>		
		<tr class="tituloC">
			<td class="red_titulo"><div align="center">#MesAC#</div></td>
			<td class="red_titulo"><div align="center"><strong>#totparcialgesol#</strong></div></td>
			<td class="red_titulo"><div align="center">#pendtrat#</div></td>
			<td class="red_titulo"><div align="center">#totparcialgesolpendtrat#</div></td>
			<td class="red_titulo"><div align="center"><strong>#Acum_Per_GE#</strong></div></td>
			<td class="red_titulo">
				<div align="center"><button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',0,<cfoutput>#totparcialgesol#</cfoutput>,<cfoutput>#pendtrat#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar(Todos)</button></div></td>
		</tr>	
	</cfif>
	<!--- SUBORDINADORES --->	
	<cfif totExisteSB neq 0>	
		<cfset totparcialsbsol = 0>
		<cfset totparcialsbpendtrat = 0>	   
		<tr class="exibir">
			<td colspan="17" class="titulos"><div align="center">Órgãos Subordinadores</div></td>
		</tr>
		<tr class="exibir">
			<td width="10%"><div align="center"><strong>Mês</strong></div></td>
			<td width="30%"><div align="center"><strong>Quantidade (Solucionados)</strong></div></td> 
			<td width="30%"><div align="center"><strong>Outras</strong></div></td>
			<td width="16%"><div align="center"><strong>Total (*)</strong></div></td>
			<td width="10%"><div align="center">%</div></td>
			<td class="exibir">&nbsp;</td>
		</tr>	
		<cfset aux_mes_sb = 1>
		<cfloop condition="aux_mes_sb lte month(dtlimit)">
			<!--- OBTER QTD. SOLUCIONADOS --->     
			<cfquery dbtype="query" name="rstotsolmes">
				SELECT Andt_RespAnt 
				FROM  rsTodos
				where Andt_RespAnt in (4,7,16) and Andt_Mes = #aux_mes_sb# AND (Andt_Resp=3)
			</cfquery>	
			<!--- Quant. UNIDADES SOLUCIONADO --->
			<cfset totsolmes = rstotsolmes.recordcount>

			<!--- Obter PENDENTES + TRATAMENTOS DO MES  --->     
			<cfquery dbtype="query" name="rstotpendtratmes">
				SELECT Andt_Resp 
				FROM  rsTodos
				where Andt_Resp in (4,16) and Andt_Mes = #aux_mes_sb#
			</cfquery>				
			<cfset totpendtratmes = rstotpendtratmes.recordcount>

			<cfif aux_mes_sb is 1>
				<cfset mestext = 'JAN'>
				<cfset totsoljan = totsoljan + totsolmes>
				<cfset totpendtratjan = totpendtratjan + totpendtratmes>
			<cfelseif aux_mes_sb is 2>  
				<cfset mestext = 'FEV'>   
				<cfset totsolfev = totsolfev + totsolmes>
				<cfset totpendtratfev = totpendtratfev + totpendtratmes>                             
			<cfelseif aux_mes_sb is 3>
				<cfset mestext = 'MAR'>   
				<cfset totsolmar = totsolmar + totsolmes>
				<cfset totpendtratmar = totpendtratmar + totpendtratmes>                                  
			<cfelseif aux_mes_sb is 4>
				<cfset mestext = 'ABR'>	                	
				<cfset totsolabr = totsolabr + totsolmes>
				<cfset totpendtratabr = totpendtratabr + totpendtratmes>                 
			<cfelseif aux_mes_sb is 5>
				<cfset mestext = 'MAI'>	      
				<cfset totsolmai = totsolmai + totsolmes>
				<cfset totpendtratmai = totpendtratmai + totpendtratmes>                               	
			<cfelseif aux_mes_sb is 6>
				<cfset mestext = 'JUN'>	                    
				<cfset totsoljun = totsoljun + totsolmes>
				<cfset totpendtratjun = totpendtratjun + totpendtratmes>                   			   
			<cfelseif aux_mes_sb is 7>
				<cfset mestext = 'JUL'>		                  
				<cfset totsoljul = totsoljul + totsolmes>
				<cfset totpendtratjul = totpendtratjul + totpendtratmes>                     		   
			<cfelseif aux_mes_sb is 8>
				<cfset mestext = 'AGO'>			               	
				<cfset totsolago = totsolago + totsolmes>
				<cfset totpendtratago = totpendtratago + totpendtratmes>                       
			<cfelseif aux_mes_sb is 9>
				<cfset mestext = 'SET'>			                
				<cfset totsolset = totsolset + totsolmes>
				<cfset totpendtratset = totpendtratset + totpendtratmes>                        	   
			<cfelseif aux_mes_sb is 10>
				<cfset mestext = 'OUT'>                 
				<cfset totsolout = totsolout + totsolmes>
				<cfset totpendtratout = totpendtratout + totpendtratmes>                    
			<cfelseif aux_mes_sb is 11>	
				<cfset mestext = 'NOV'>	   		              
				<cfset totsolnov = totsolnov + totsolmes>
				<cfset totpendtratnov = totpendtratnov + totpendtratmes>                       		   
			<cfelse>
				<cfset mestext = 'DEZ'>		
				<cfset totsoldez = totsoldez + totsolmes>
				<cfset totpendtratdez = totpendtratdez + totpendtratmes>                   	                   	   
			</cfif>
			<cfset totparcialsbsol = totparcialsbsol + totsolmes>
			<cfset totparcialsbpendtrat = totparcialsbpendtrat + totpendtratmes>
			<tr class="exibir">
				<td><div align="center"><strong>#mestext#</strong></div></td>
				<td><div align="center"><strong>#totsolmes#</strong></div></td>
				<cfset habunidsn = ''>
				<cfif mestext eq 0>
					<cfset habunidsn = 'disabled'>
				</cfif>
				<cfif totsolmes neq 0>
					<cfset Per = NumberFormat(totsolmes/(totsolmes + totpendtratmes)* 100,999.0)>
				<cfelse>
					<cfset Per = 0>
				</cfif>
				<td><div align="center"><strong>#totpendtratmes#</strong></div></td>
				<td><div align="center"><strong>#(totsolmes + totpendtratmes)#</strong></div></td>
				<td><div align="center">#NumberFormat(Per,999.0)#</div></td> 	
				<td width="19%" class="exibir"><div align="center"><button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb','#aux_mes_sb#',<cfoutput>#totsolmes#</cfoutput>,<cfoutput>#totpendtratmes#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button></div></td>	
			</tr>
                <cfset aux_mes_sb = aux_mes_sb + 1>
        </cfloop>		
	
		<tr class="exibir">
			<td colspan="17"><hr></td>
		</tr>
		<cfset totparcialsbsolpendtrat = (totparcialsbsol + totparcialsbpendtrat)>
		<cfset pendtrat=(totparcialsbsolpendtrat - totparcialsbsol)>
		<cfset Acum_Per_SB = 0> 
		<cfif totparcialsbsol gt 0>
			<cfset Acum_Per_SB = NumberFormat(((totparcialsbsol/totparcialsbsolpendtrat) * 100),999.0)>
		</cfif>		
		<tr class="tituloC">
			<td class="red_titulo"><div align="center">#MesAC#</div></td>
			<td class="red_titulo"><div align="center"><strong>#totparcialsbsol#</strong></div></td>
			<td class="red_titulo"><div align="center">#pendtrat#</div></td>
			<td class="red_titulo"><div align="center">#totparcialsbsolpendtrat#</div></td>
			<td class="red_titulo"><div align="center"><strong>#Acum_Per_SB#</strong></div></td>
			<td class="red_titulo">
				<div align="center"><button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',0,<cfoutput>#totparcialsbsol#</cfoutput>,<cfoutput>#pendtrat#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar(Todos)</button></div></td>
		</tr>	
	</cfif>
	<!--- SUPERINTENDENTES --->	
	<cfif totExisteSU neq 0>	
		<cfset totparcialsusol = 0>
		<cfset totparcialsupendtrat = 0>      
		<tr class="exibir">
			<td colspan="17" class="titulos"><div align="center">Superintendência</div></td>
		</tr>
		<tr class="exibir">
			<td width="10%"><div align="center"><strong>Mês</strong></div></td>
			<td width="30%"><div align="center"><strong>Quantidade (Solucionados)</strong></div></td> 
			<td width="30%"><div align="center"><strong>Outras</strong></div></td>
			<td width="16%"><div align="center"><strong>Total (*)</strong></div></td>
			<td width="10%"><div align="center">%</div></td>
			<td class="exibir">&nbsp;</td>
		</tr>
		<cfset aux_mes_su = 1>
		<cfloop condition="aux_mes_su lte month(dtlimit)">
			<!--- OBTER QTD. SOLUCIONADOS --->     
			<cfquery dbtype="query" name="rstotsolmes">
				SELECT Andt_RespAnt 
				FROM  rsTodos
				where Andt_RespAnt in (8,22,23) and Andt_Mes = #aux_mes_su# AND (Andt_Resp=3)
			</cfquery>	
			<!--- Quant. UNIDADES SOLUCIONADO --->
			<cfset totsolmes = rstotsolmes.recordcount>

			<!--- Obter PENDENTES + TRATAMENTOS DO MES  --->     
			<cfquery dbtype="query" name="rstotpendtratmes">
				SELECT Andt_Resp 
				FROM  rsTodos
				where Andt_Resp in (8,23) and Andt_Mes = #aux_mes_su# 
			</cfquery>				
			<cfset totpendtratmes = rstotpendtratmes.recordcount>

			<cfif aux_mes_su is 1>
				<cfset mestext = 'JAN'>
				<cfset totsoljan = totsoljan + totsolmes>
				<cfset totpendtratjan = totpendtratjan + totpendtratmes>
			<cfelseif aux_mes_su is 2>  
				<cfset mestext = 'FEV'>   
				<cfset totsolfev = totsolfev + totsolmes>
				<cfset totpendtratfev = totpendtratfev + totpendtratmes>                             
			<cfelseif aux_mes_su is 3>
				<cfset mestext = 'MAR'>   
				<cfset totsolmar = totsolmar + totsolmes>
				<cfset totpendtratmar = totpendtratmar + totpendtratmes>                                  
			<cfelseif aux_mes_su is 4>
				<cfset mestext = 'ABR'>	                	
				<cfset totsolabr = totsolabr + totsolmes>
				<cfset totpendtratabr = totpendtratabr + totpendtratmes>                 
			<cfelseif aux_mes_su is 5>
				<cfset mestext = 'MAI'>	      
				<cfset totsolmai = totsolmai + totsolmes>
				<cfset totpendtratmai = totpendtratmai + totpendtratmes>                               	
			<cfelseif aux_mes_su is 6>
				<cfset mestext = 'JUN'>	                    
				<cfset totsoljun = totsoljun + totsolmes>
				<cfset totpendtratjun = totpendtratjun + totpendtratmes>                   			   
			<cfelseif aux_mes_su is 7>
				<cfset mestext = 'JUL'>		                  
				<cfset totsoljul = totsoljul + totsolmes>
				<cfset totpendtratjul = totpendtratjul + totpendtratmes>                     		   
			<cfelseif aux_mes_su is 8>
				<cfset mestext = 'AGO'>			               	
				<cfset totsolago = totsolago + totsolmes>
				<cfset totpendtratago = totpendtratago + totpendtratmes>                       
			<cfelseif aux_mes_su is 9>
				<cfset mestext = 'SET'>			                
				<cfset totsolset = totsolset + totsolmes>
				<cfset totpendtratset = totpendtratset + totpendtratmes>                        	   
			<cfelseif aux_mes_su is 10>
				<cfset mestext = 'OUT'>                 
				<cfset totsolout = totsolout + totsolmes>
				<cfset totpendtratout = totpendtratout + totpendtratmes>                    
			<cfelseif aux_mes_su is 11>	
				<cfset mestext = 'NOV'>	   		              
				<cfset totsolnov = totsolnov + totsolmes>
				<cfset totpendtratnov = totpendtratnov + totpendtratmes>                       		   
			<cfelse>
				<cfset mestext = 'DEZ'>		
				<cfset totsoldez = totsoldez + totsolmes>
				<cfset totpendtratdez = totpendtratdez + totpendtratmes>                   	                   	   
			</cfif>
			<cfset totparcialsusol = totparcialsusol + totsolmes>
			<cfset totparcialsupendtrat = totparcialsupendtrat + totpendtratmes>
			<tr class="exibir">
				<td><div align="center"><strong>#mestext#</strong></div></td>
				<td><div align="center"><strong>#totsolmes#</strong></div></td>
				<cfset habunidsn = ''>
				<cfif mestext eq 0>
					<cfset habunidsn = 'disabled'>
				</cfif>
				<cfif totsolmes neq 0>
					<cfset Per = NumberFormat(totsolmes/(totsolmes + totpendtratmes)* 100,999.0)>
				<cfelse>
					<cfset Per = 0>
				</cfif>
				<td><div align="center"><strong>#totpendtratmes#</strong></div></td>
				<td><div align="center"><strong>#(totsolmes + totpendtratmes)#</strong></div></td>
				<td><div align="center">#NumberFormat(Per,999.0)#</div></td> 	
				<td width="19%" class="exibir"><div align="center"><button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su','#aux_mes_su#',<cfoutput>#totsolmes#</cfoutput>,<cfoutput>#totpendtratmes#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button></div></td>	
			</tr>
                <cfset aux_mes_su = aux_mes_su + 1>
        </cfloop>		

		<tr class="exibir">
			<td colspan="17"><hr></td>
		</tr>

		<cfset totparcialsusolpendtrat = (totparcialsusol + totparcialsupendtrat)>
		<cfset pendtrat=(totparcialsusolpendtrat - totparcialsusol)>
		<cfset Acum_Per_SU = 0> 
		<cfif totparcialsusol gt 0>
			<cfset Acum_Per_SU = NumberFormat(((totparcialsusol/totparcialsusolpendtrat) * 100),999.0)>
		</cfif>		
		<tr class="tituloC">
			<td class="red_titulo"><div align="center">#MesAC#</div></td>
			<td class="red_titulo"><div align="center"><strong>#totparcialsusol#</strong></div></td>
			<td class="red_titulo"><div align="center">#pendtrat#</div></td>
			<td class="red_titulo"><div align="center">#totparcialsusolpendtrat#</div></td>
			<td class="red_titulo"><div align="center"><strong>#Acum_Per_SU#</strong></div></td>
			<td class="red_titulo">
				<div align="center"><button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'su',0,<cfoutput>#totparcialsusol#</cfoutput>,<cfoutput>#pendtrat#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar(Todos)</button></div></td>
		</tr>	
	</cfif> 
  </table>

<!--- Criação do arquivo CSV --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.csv'>


<!--- Excluir arquivos anteriores ao dia atual --->
<cfdirectory name="qList" filter="*.csv" sort="name desc" directory="#slocal#">
<cfloop query="qList">
	<cfif (left(name,8) lt left(sdata,8)) or (mid(name,12,8) eq trim(qUsuario.Usu_Matricula))>
	  <cffile action="delete" file="#slocal##name#">
	</cfif>
</cfloop>
<cffile action="write" addnewline="no" file="#slocal##sarquivo#" output=''>
<cffile action="Append" file="#slocal##sarquivo#" output='SOLUÇÃO DE NÃO CONFORMIDADES (SLNC) - #auxfilta#' >
<cffile action="Append" file="#slocal##sarquivo#" output=';;A;B*;C**;D;E=((C*100)/D);'>
<cffile action="Append" file="#slocal##sarquivo#" output='SE;Mês;Quantidade (Solucionados);Total;% de SL do mês;Meta Mensal;% Em Relação à meta Mensal;Resultado'>
<table width="56%" border="1" align="center" cellpadding="0" cellspacing="0">

  <tr>
	<td colspan="13"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="45" height="45" border="0"></a></div></td>
</tr>
  <tr>
    <td colspan="23" class="titulos"><div align="center"><strong>SOLUÇÃO DE NÃO CONFORMIDADES (SLNC) </strong></div></td>
  </tr>
  <tr>
    <td colspan="23" class="exibir"><div align="center"></div></td>
  </tr>
  <tr class="exibir">
    <td colspan="12"><div align="center"></div>      <div align="center"></div>        <div align="center"></div></td>
  </tr>
<tr class="exibir">
      <td colspan="2">&nbsp;</td>
      <td><div align="center">A</div></td>
      <td><div align="center">B*</div></td>
      <td><div align="center">C**</div></td>
   <!---    <td><div align="center">D</div></td> --->
<!---       <td><div align="center">E</div></td> --->
      <td><div align="center">D</div></td>
      <td><div align="center">E = ((C * 100)/D) </div></td>
      <td>&nbsp;</td>
    </tr>
  <tr class="exibir">
    <td width="4%" rowspan="2" valign="middle"><div align="center"><strong>SE</strong></div></td>
    <td width="7%" rowspan="2" valign="middle"><div align="center"><strong>Mês</strong></div></td>
    <td class="exibir"><div align="center"><strong>Quantidade (Solucionados)</strong></div>      
    <div align="center"></div><div align="center"></div></td>
    <td width="7%" class="exibir"><div align="center"><strong>Total</strong></div></td>
    <td width="8%" class="exibir"><div align="center"><strong>% de SL do mês </strong></div></td>
    <td width="10%" class="exibir"><div align="center"><strong>Meta<br>Mensal</strong> </div></td>
    <td width="14%" class="exibir"><div align="center"><strong>Em relação à Meta Mensal</strong> </div></td>
    <td width="16%" class="exibir"><div align="center"><strong>Resultado</strong> </div></td>
  </tr>
    <tr class="exibir">
    <td colspan="11" class="exibir"><div align="center" class="titulos"></div>      <div align="center" class="titulos"></div>      <div align="center" class="titulos"></div></td>
    </tr>
<CFSET sg = qAcesso.Dir_Sigla>
<CFSET colbano = 0>
<CFSET colcano = 0>
<cfset totgersol = 0>
<cfset totgerpendtrat = 0>
<!--- Criar linha de metas --->
<cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT Met_PRCI_Mes,Met_SLNC_Mes,Met_DGCI_Mes
	FROM Metas
	WHERE Met_Codigo='#se#' and Met_Ano = #anoexerc# and Met_Mes = 1
</cfquery>
<!--- JAN --->	
<cfif (month(dtlimit) gte 1)>
  	<cfset siglames = 'JAN'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>JAN</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsoljan#</strong></div></td>
		<cfset colB = NumberFormat(((totsoljan + totpendtratjan)),999)>
		<cfif (totsoljan + totpendtratjan) eq 0>
		 	<cfset colB='100.0'>
		</cfif>
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsoljan/colB) * 100),999.0))>
		<cfif (totsoljan + totpendtratjan) eq 0>
		 	<cfset colC='100.0'>
		</cfif>				
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 1>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;JAN;#totsoljan#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>
 </cfif>
<!--- FEV --->
<cfif (month(dtlimit) gte 2)>
  	<cfset siglames = 'FEV'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>FEV</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsolfev#</strong></div></td>
		<cfset colB = NumberFormat(((totsolfev + totpendtratfev)),999)>
		<cfif (totsolfev + totpendtratfev) eq 0>
		 	<cfset colB='100.0'>
		</cfif>			
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsolfev/colB) * 100),999.0))>	
		<cfif (totsolfev + totpendtratfev) eq 0>
		 	<cfset colC='100.0'>
		</cfif>		
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 2>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;FEV;#totsolfev#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>	
 </cfif>
<!--- MAR --->
<cfif (month(dtlimit) gte 3)>
	<cfset siglames = 'MAR'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>MAR</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsolmar#</strong></div></td>
		<cfset colB = NumberFormat(((totsolmar + totpendtratmar)),999)>
		<cfif (totsolmar + totpendtratmar) eq 0>
		 	<cfset colB='100.0'>
		</cfif>
		<cfset colbano = colbano + colB>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsolmar/colB) * 100),999.0))>	
		<cfif (totsolmar + totpendtratmar) eq 0>
		 	<cfset colC='100.0'>
		</cfif>
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 3>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;MAR;#totsolmar#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>
 </cfif> 
<!--- ABR --->
<cfif (month(dtlimit) gte 4)>
	<cfset siglames = 'ABR'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>ABR</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsolabr#</strong></div></td>
		<cfset colB = NumberFormat(((totsolabr + totpendtratabr)),999)>
		<cfif (totsolabr + totpendtratabr) eq 0>
		 	<cfset colB='100.0'>
		</cfif>		
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsolabr/colB) * 100),999.0))>	
		<cfif (totsolabr + totpendtratabr) eq 0>
		 	<cfset colC='100.0'>
		</cfif>		
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 4>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;ABR;#totsolabr#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>	
 </cfif>   
<!--- MAI --->
<cfif (month(dtlimit) gte 5)>
	<cfset siglames = 'MAI'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>MAI</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsolmai#</strong></div></td>
		<cfset colB = NumberFormat(((totsolmai + totpendtratmai)),999)>
		<cfif (totsolmai + totpendtratmai) eq 0>
		 	<cfset colB='100.0'>
		</cfif>			
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsolmai/colB) * 100),999.0))>	
		<cfif (totsolmai + totpendtratmai) eq 0>
		 	<cfset colC='100.0'>
		</cfif>	
	
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<cfif #anoexerc# eq 2024 and #se# eq '64'>
			<cfset resultado = "SUSPENSO">
			<cfset auxcor = "">
			<cfset totsolmai=0>
			<cfset colbano = colbano - colb>
		</cfif> 
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 5>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;MAI;#totsolmai#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>
 </cfif> 
<!--- JUN --->
<cfif (month(dtlimit) gte 6)>
	<cfset siglames = 'JUN'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>JUN</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsoljun#</strong></div></td>
		<cfset colB = NumberFormat(((totsoljun + totpendtratjun)),999)>
		<cfif (totsoljun + totpendtratjun) eq 0>
		 	<cfset colB='100.0'>
		</cfif>				
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsoljun/colB) * 100),999.0))>	
		<cfif (totsoljun + totpendtratjun) eq 0>
		 	<cfset colC='100.0'>
		</cfif>			
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<cfif #anoexerc# eq 2024 and #se# eq '64'>
			<cfset resultado = "SUSPENSO">
			<cfset auxcor = "">
			<cfset totsoljun=0>
			<cfset colbano = colbano - colb>
		</cfif>		
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 6>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;JUN;#totsoljun#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>	
 </cfif> 
 <!--- JUL --->	
<cfif (month(dtlimit) gte 7)>
	<cfset siglames = 'JUL'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>JUL</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsoljul#</strong></div></td>
		<cfset colB = NumberFormat(((totsoljul + totpendtratjul)),999)>
		<cfif (totsoljul + totpendtratjul) eq 0>
		 	<cfset colB='100.0'>
		</cfif>			
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsoljul/colB) * 100),999.0))>	
		<cfif (totsoljul + totpendtratjul) eq 0>
		 	<cfset colC='100.0'>
		</cfif>				
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<cfif #anoexerc# eq 2024 and #se# eq '64'>
			<cfset resultado = "SUSPENSO">
			<cfset auxcor = "">
			<cfset totsoljul=0>
			<cfset colbano = colbano - colb>
		</cfif>	
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 7>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;JUL;#totsoljul#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>
 </cfif>
<!--- AGO --->
<cfif (month(dtlimit) gte 8)>
	<cfset siglames = 'AGO'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>AGO</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsolago#</strong></div></td>
		<cfset colB = NumberFormat(((totsolago + totpendtratago)),999)>
		<cfif (totsolago + totpendtratago) eq 0>
		 	<cfset colB='100.0'>
		</cfif>			
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsolago/colB) * 100),999.0))>	
		<cfif (totsolago + totpendtratago) eq 0>
		 	<cfset colC='100.0'>
		</cfif>			
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<cfif #anoexerc# eq 2024 and #se# eq '64'>
			<cfset resultado = "SUSPENSO">
			<cfset auxcor = "">
			<cfset totsolago=0>
			<cfset colbano = colbano - colb>
		</cfif>	
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 8>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;AGO;#totsolago#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>	
 </cfif> 
<!--- SET --->
<cfif (month(dtlimit) gte 9)>
	<cfset siglames = 'SET'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>SET</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsolset#</strong></div></td>
		<cfset colB = NumberFormat(((totsolset + totpendtratset)),999)>
		<cfif (totsolset + totpendtratset) eq 0>
		 	<cfset colB='100.0'>
		</cfif>			
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsolset/colB) * 100),999.0))>	
		<cfif (totsolset + totpendtratset) eq 0>
		 	<cfset colC='100.0'>
		</cfif>			
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<cfif #anoexerc# eq 2024 and #se# eq '64'>
			<cfset resultado = "SUSPENSO">
			<cfset auxcor = "">
			<cfset totsolset=0>
			<cfset colbano = colbano - colb>
		</cfif>			
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 9>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;SET;#totsolset#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>	
 </cfif> 
<!--- OUT --->
<cfif (month(dtlimit) gte 10)>
	<cfset siglames = 'OUT'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>OUT</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsolout#</strong></div></td>
		<cfset colB = NumberFormat(((totsolout + totpendtratout)),999)>
		<cfif (totsolout + totpendtratout) eq 0>
		 	<cfset colB='100.0'>
		</cfif>			
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsolout/colB) * 100),999.0))>	
		<cfif (totsolout + totpendtratout) eq 0>
		 	<cfset colC='100.0'>
		</cfif>				
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<cfif #anoexerc# eq 2024 and #se# eq '64'>
			<cfset resultado = "SUSPENSO">
			<cfset auxcor = "">
			<cfset totsolout=0>
			<cfset colbano = colbano - colb>
		</cfif>	
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 10>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;OUT;#totsolout#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>
 </cfif> 
<!--- NOV --->
<cfif (month(dtlimit) gte 11)>
	<cfset siglames = 'NOV'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>NOV</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsolnov#</strong></div></td>
		<cfset colB = NumberFormat(((totsolnov + totpendtratnov)),999)>
		<cfif (totsolnov + totpendtratnov) eq 0>
		 	<cfset colB='100.0'>
		</cfif>			
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsolnov/colB) * 100),999.0))>	
		<cfif (totsolnov + totpendtratnov) eq 0>
		 	<cfset colC='100.0'>
		</cfif>			
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<cfif #anoexerc# eq 2024 and #se# eq '64'>
			<cfset resultado = "SUSPENSO">
			<cfset auxcor = "">
			<cfset totsolnov=0>
			<cfset colbano = colbano - colb>
		</cfif>			
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 11>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;NOV;#totsolnov#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>
 </cfif>
<!--- DEZ --->
<cfif (month(dtlimit) gte 12)>
	<cfset siglames = 'DEZ'>
    <tr class="exibir">
		<td><div align="center"><strong>#sg#</strong></div></td>
		<td><div align="center"><strong>DEZ</strong></div></td>
		<td width="14%" class="exibir"><div align="center"><strong>#totsoldez#</strong></div></td>
		<cfset colB = NumberFormat(((totsoldez + totpendtratdez)),999)>
		<cfif (totsoldez + totpendtratdez) eq 0>
		 	<cfset colB='100.0'>
		</cfif>			
		<cfset colbano = colbano + colb>
		<td><div align="center"><strong>#colB#</strong></div></td>
		<cfset colC = trim(NumberFormat(((totsoldez/colB) * 100),999.0))>	
		<cfif (totsoldez + totpendtratdez) eq 0>
		 	<cfset colC='100.0'>
		</cfif>			
		<td><div align="center">#colC#</div></td>
		<cfset ColD = rsMetas.Met_SLNC_Mes>    
		<td><div align="center">#ColD#</div></td>
		<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
		<td><div align="center">#ColE#</div></td>
		<cfif ColC gt ColD>
			<cfset resultado = "ACIMA DO ESPERADO">
			<cfset auxcor = "##33CCFF">
		<cfelseif ColC eq ColD>		
			<cfset resultado = "DENTRO DO ESPERADO">
			<cfset auxcor = "##339900">
		<cfelse>
			<cfset resultado = "ABAIXO DO ESPERADO">
			<cfset auxcor = "##FF3300">
		</cfif>	
		<cfif #anoexerc# eq 2024 and #se# eq '64'>
			<cfset resultado = "SUSPENSO">
			<cfset auxcor = "">
			<cfset totsoldez=0>
			<cfset colbano = colbano - colb>
		</cfif>	
		<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 12>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;DEZ;#totsoldez#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>	
 </cfif>  
	<cfset totgersol = totsoljan + totsolfev + totsolmar + totsolabr + totsolmai + totsoljun + totsoljul + totsolago + totsolset + totsolout + totsolnov + totsoldez>
	<cfset totgerpendtrat = totpendtratjan + totpendtratfev + totpendtratmar + totpendtratabr + totpendtratmai + totpendtratjun + totpendtratjul + totpendtratago + totpendtratset + totpendtratout + totpendtratnov + totpendtratdez>
	<cfset colcano = trim(NumberFormat(((totgersol/(totgersol + totgerpendtrat)) * 100),999.0))>	
	<cfset ColD = rsMetas.Met_SLNC_Mes> 
	<CFSET ColE = numberFormat(((colcano * 100)/ColD),999.0)>
<tr class="titulos">
    <td><div align="center" class="red_titulo"><strong>#sg#</strong></div></td>  
    <td class="red_titulo"><div align="center"><strong>Geral</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#totgersol#</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#colbano#</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#colcano#</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#ColD#</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#ColE#</strong></div></td>

   <cfif colcano gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif colcano eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
 <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;Geral;#totgersol#;#colbano#;#colcano#;#colD#;#ColE#;#resultado#'>
  <tr class="exibir">
    <td colspan="12" class="exibir"><strong>Legenda: </strong></td>
  </tr>
   <cffile action="Append" file="#slocal##sarquivo#" output='Legenda:'>
  <tr class="exibir">
    <td colspan="12"><strong>* Total B - Soma ((pendentes + tratamento com mais de  30(trinta) dias úteis  da liberação dos pontos) + ( solucionados do mês)) </strong></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='* Total B - Soma ((pendentes + tratamento com mais de  30(trinta) dias úteis  da liberação dos pontos) + ( solucionados do mês)) ' >
  <tr class="exibir">
    <td colspan="12"><strong>** % de SL do m&ecirc;s = ((A/B) * 100) </strong></td>
  </tr>
   <cffile action="Append" file="#slocal##sarquivo#" output='** % de SL do mês = A/B * 100'>  

    <tr class="exibir">
    <td colspan="12"><p><strong>SL = SOLUCIONADO <br></strong></p></td>
<cfif frmano eq anoatual>	
  <cfset dtini = dateformat(now(),"DD/MM/YYYY")>
  <cfset dtini = '01' & right(dtini,8)>
  <cfset dtfim = now()>
  <cfset dtfim = DateAdd( "d", -1, dtfim)>
    <tr class="exibir">
      <td colspan="18" class="exibir"><strong>#siglames#&nbsp;&nbsp;&nbsp;Período de  #dtini#  até  #dateformat(dtfim,"DD/MM/YYYY")#</strong></td>
    </tr>
</cfif>	
  <cffile action="Append" file="#slocal##sarquivo#" output='SL = SOLUCIONADO'>  
<cfif frmano eq anoatual> 	
  <cffile action="Append" file="#slocal##sarquivo#" output='#siglames#&nbsp;&nbsp;&nbsp;Período de  #dtini#  até  #dateformat(dtfim,"DD/MM/YYYY")#'>  	  
</cfif>
  </tr>
</table>

<input name="se" type="hidden" value="#se#">


<!--- fim exibicao --->
</form>
<form name="formx" method="post" action="slnc2.cfm" target="_blank">
    <input name="lis_anoexerc" type="hidden" value="#anoexerc#">
	<input name="lis_se" type="hidden" value="#se#">
	<input name="lis_mes" type="hidden" value="">
	<input name="lis_soluc" type="hidden" value="">
	<input name="lis_outros" type="hidden" value="">
	<input name="lis_grpace" type="hidden" value="">
</form>
  <cfinclude template="rodape.cfm">
</body>
</html>
</cfoutput>
