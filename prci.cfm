<!---
  <cfdump  var="#url#">
  <cfoutput>
 #dtlimit#
 </cfoutput>
<cfset gil = gil>
--->

<!--- versão anterior --->
<cfif frmano lte 2022>
	<cflocation url="prci_2022.cfm?se=#se#&frmano=#frmano#&Submit1=Confirmar&dtlimit=#dtlimit#&dtlimitatual=#dtlimitatual#&anoexerc=#frmano#&anoatual=#anoatual#">
</cfif> 

<cfsetting requesttimeout="15000">
<cfprocessingdirective pageEncoding ="utf-8"/>
<cfoutput>

	<cfquery name="qUsuario" datasource="#dsn_inspecao#">
		select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
	</cfquery>
  <cfset grpacesso = ucase(Trim(qUsuario.Usu_GrupoAcesso))>
<cfset dia = day(now())>
<cfset mes = month(now())>
<cfset ano = year(now())>
<cfset aux_mes = month(dtlimit)>
<cfset aux_ano = year(dtlimit)>
<cfif (grpacesso neq 'GESTORMASTER') and (aux_ano neq ano) and (mes eq 1) and (dia lte 10)>
  <cfset ano = aux_ano>
</cfif>
<cfif grpacesso neq 'GESTORMASTER' and dia lte 10 and aux_ano eq ano>
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
<!--- 
  <cfoutput>#se#  === #anoexerc#  === #dtlimit#<br></cfoutput>
 <CFSET GIL = GIL> --->  

	<cfset total=0>

	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		SELECT Dir_codigo, Dir_Sigla, Dir_Descricao FROM Diretoria WHERE Dir_codigo = '#se#'
	</cfquery>
	<cfset auxfilta = #qAcesso.Dir_Descricao#>
	<cfset auxfiltb = 'SE/' & #qAcesso.Dir_Sigla#>
</cfoutput>
<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="css.css" rel="stylesheet" type="text/css">
<script language="javascript">

//=============================
function listar(a,b,c,d){
	document.formx.lis_se.value=a;
	document.formx.lis_grpace.value=b;
    document.formx.lis_mes.value=c;
    document.formx.lis_ano.value=d;
	document.formx.submit(); 
}

</script>
<link href="css.css" rel="stylesheet" type="text/css">
</head>
<body>
<form action="prci2.cfm" method="post" target="_blank" name="form1">
<cfoutput>
	<cfset totgerDP = 0>
	<cfset totgerFP = 0>
	<cfset totjanDP = 0>
  <cfset totfevDP = 0>
  <cfset totmarDP = 0>
  <cfset totabrDP = 0>
  <cfset totmaiDP = 0>
  <cfset totjunDP = 0>
  <cfset totjulDP = 0>
  <cfset totagoDP = 0>
  <cfset totsetDP = 0>
  <cfset totoutDP = 0>
  <cfset totnovDP = 0>
  <cfset totdezDP = 0>

  <cfset totjanFP = 0>
  <cfset totfevFP = 0>
  <cfset totmarFP = 0>
  <cfset totabrFP = 0>
  <cfset totmaiFP = 0>
  <cfset totjunFP = 0>
  <cfset totjulFP = 0>
  <cfset totagoFP = 0>
  <cfset totsetFP = 0>
  <cfset totoutFP = 0>
  <cfset totnovFP = 0>
  <cfset totdezFP = 0>
	
    <!--- exibicao em tela --->
	<cfquery name="rsBaseB" datasource="#dsn_inspecao#">
		SELECT Andt_Unid as UNID, Andt_Insp as INSP, Andt_Grp as Grupo, Andt_Item as Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_Mes, Andt_Prazo
		FROM Andamento_Temp 
		where (Andt_CodSE = '#se#' and Andt_TipoRel = 1 and Andt_AnoExerc = '#year(dtlimit)#' and Andt_Mes <= #month(dtlimit)#)
    order by Andt_Mes
	</cfquery>
    <cfset auxtit = "SE: " & #qAcesso.Dir_codigo# & "-" & #qAcesso.Dir_Sigla#>
  
    <table width="45%" border="1" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td colspan="17"><div align="center" class="titulo1"><strong>#auxfilta#</strong></div></td>
        </tr>
        <tr>
            <td colspan="17">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="17"><div align="center"><span class="titulo1"><strong>Atendimento ao Prazo de Resposta do Controle Interno (PRCI)</strong></span></div></td>
        </tr>
        <tr>
            <td colspan="17">&nbsp;</td>
        </tr>

        <cfset aux_mes = rsBaseB.Andt_Mes>
        <cfset tpunid = rsBaseB.Andt_tpunid>
        <cfset rsMes_status = rsBaseB.Andt_Resp>

        <!--- Unidades  e Terceiros (DP + FP) --->
        <!--- quant. (DP + FP) --->
        <cfquery dbtype="query" name="rstotmesunidDPFP">
            SELECT Andt_Prazo 
            FROM  rsBaseB
            where Andt_Resp in (1,17,2,14,15,18,20) and Andt_Mes <= #month(dtlimit)#
        </cfquery>
        <cfset totmesunidDPFP = rstotmesunidDPFP.recordcount>

        <!--- contar AREAS (DP + FP) --->
        <!--- quant. (DP + FP) --->
        <cfquery dbtype="query" name="rstotmesgeDPFP">
            SELECT Andt_Prazo 
            FROM  rsBaseB
            where Andt_Resp in (6,5,19) and Andt_Mes <= #month(dtlimit)#
        </cfquery>
        <cfset totmesgeDPFP = rstotmesgeDPFP.recordcount>

        <!--- contar orgao subordinadores (DP + FP) --->
        <!--- quant. (DP + FP) --->
        <cfquery dbtype="query" name="rstotmessbDPFP">
            SELECT Andt_Prazo 
            FROM  rsBaseB
            where Andt_Resp in (4,7,16) and Andt_Mes <= #month(dtlimit)#
        </cfquery>
        <cfset totmessbDPFP = rstotmessbDPFP.recordcount>

        <!--- contar superintendencia (DP + FP) --->
        <!--- quant. (DP + FP) --->
        <cfquery dbtype="query" name="rstotmessuDPFP">
            SELECT Andt_Prazo 
            FROM  rsBaseB
            where Andt_Resp in (8,22,23) and Andt_Mes <= #month(dtlimit)#
        </cfquery>
        <cfset totmessuDPFP = rstotmessuDPFP.recordcount>  

        <!--- UNIDADES --->
        <cfif totmesunidDPFP neq 0>	   
            <cfif aux_mes eq 1>
                <tr class="exibir">
                    <td colspan="7" class="titulos"><div align="center">Unidades</div></td>
                </tr>
                <tr class="exibir">
                    <td><div align="center"><strong>Mês</strong></div></td>
                    <td width="21%"><div align="center"><strong>Dentro prazo</strong></div></td>
                    <td width="13%"><div align="center">%(DP)</div></td>
                    <td width="17%"><div align="center"><strong>Fora prazo</strong></div></td>
                    <td width="13%"><div align="center">%(FP)</div></td>
                    <td><div align="center"><strong>Total</strong></div></td>
                    <td>&nbsp;</td>
                    <td width="1%"></td>    
                </tr>
            </cfif>    
            <cfset aux_mes_unid = 1>
            <cfset un_dp_soma = 0>
	          <cfset un_fp_soma = 0>
            <cfloop condition="aux_mes_unid lte month(dtlimit)">
                <!--- Obter quantidades para montar quadro final --->     
                <!--- Quant. (DP + FP) --->
                <cfquery dbtype="query" name="rstotmesunDPFP">
                    SELECT Andt_Prazo 
                    FROM  rsBaseB
                    where Andt_Resp in (1,17,2,14,15,18,20) and Andt_Mes = #aux_mes_unid#
                </cfquery>
                <cfset totmesunDPFP = rstotmesunDPFP.recordcount>

                <!--- Quant. DP --->
                <cfquery dbtype="query" name="rstotmesunDP">
                    SELECT Andt_Prazo 
                    FROM  rsBaseB
                    where Andt_Resp in (1,17,2,14,15,18,20) and Andt_Mes = #aux_mes_unid# and Andt_Prazo = 'DP'
                </cfquery>
                <cfset totmesunDP = rstotmesunDP.recordcount>

                <!--- Quant. FP --->
                <cfset totmesunFP = (totmesunDPFP - totmesunDP)>

                <cfif aux_mes_unid is 1>
                    <cfset mestext = 'JAN'>
                    <cfset totjanDP = totjanDP + totmesunDP>
                    <cfset totjanFP = totjanFP + totmesunFP>
                <cfelseif aux_mes_unid is 2>  
                    <cfset mestext = 'FEV'>   
                    <cfset totfevDP = totfevDP + totmesunDP>
                    <cfset totfevFP = totfevFP + totmesunFP>                              
                <cfelseif aux_mes_unid is 3>
                    <cfset mestext = 'MAR'>   
                    <cfset totmarDP = totmarDP + totmesunDP>
                    <cfset totmarFP = totmarFP + totmesunFP>                                   
                <cfelseif aux_mes_unid is 4>
                    <cfset mestext = 'ABR'>	                	
                    <cfset totabrDP = totabrDP + totmesunDP>
                    <cfset totabrFP = totabrFP + totmesunFP>                      
                <cfelseif aux_mes_unid is 5>
                    <cfset mestext = 'MAI'>	      
                    <cfset totmaiDP = totmaiDP + totmesunDP>
                    <cfset totmaiFP = totmaiFP + totmesunFP>                                  	
                <cfelseif aux_mes_unid is 6>
                    <cfset mestext = 'JUN'>	                    
                    <cfset totjunDP = totjunDP + totmesunDP>
                    <cfset totjunFP = totjunFP + totmesunFP>                       			   
                <cfelseif aux_mes_unid is 7>
                    <cfset mestext = 'JUL'>		                  
                    <cfset totjulDP = totjulDP + totmesunDP>
                    <cfset totjulFP = totjulFP + totmesunFP>                       		   
                <cfelseif aux_mes_unid is 8>
                    <cfset mestext = 'AGO'>			               	
                    <cfset totagoDP = totagoDP + totmesunDP>
                    <cfset totagoFP = totagoFP + totmesunFP>                         
                <cfelseif aux_mes_unid is 9>
                    <cfset mestext = 'SET'>			                
                    <cfset totsetDP = totsetDP + totmesunDP>
                    <cfset totsetFP = totsetFP + totmesunFP>                        	   
                <cfelseif aux_mes_unid is 10>
                    <cfset mestext = 'OUT'>                 
                    <cfset totoutDP = totoutDP + totmesunDP>
                    <cfset totoutFP = totoutFP + totmesunFP>                      
                <cfelseif aux_mes_unid is 11>	
                    <cfset mestext = 'NOV'>	   		              
                    <cfset totnovDP = totnovDP + totmesunDP>
                    <cfset totnovFP = totnovFP + totmesunFP>                           		   
                <cfelse>
                    <cfset mestext = 'DEZ'>		
                    <cfset totdezDP = totdezDP + totmesunDP>
                    <cfset totdezFP = totdezFP + totmesunFP>                      	                   	   
                </cfif> 
                <cfif totmesunDPFP gt 0>
                    <cfset PerFP = NumberFormat(((totmesunFP/totmesunDPFP) * 100),999.0)>
                    <cfset PerDP = NumberFormat(((totmesunDP/totmesunDPFP) * 100),999.0)>      
                    <tr class="exibir">
                        <td><div align="center"><strong>#mestext#</strong></div></td>
                        <td><div align="center"><strong>#totmesunDP#</strong></div></td>
                        <td><div align="center">#PerDP#</div></td>
                        <td><div align="center"><strong>#totmesunFP#</strong></div></td>
                        <td><div align="center" class="red_titulo">#PerFP#</div></td>
                        <td><div align="center"><strong>#totmesunDPFP#</strong></div></td>
                        <td width="13%" class="exibir"><div align="center"><button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un','#aux_mes_unid#',<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button></div><td>
                    </tr>
                    <cfset un_dp_soma = un_dp_soma + totmesunDP>
                    <cfset un_fp_soma = un_fp_soma + totmesunFP>
                </cfif>  
                <cfset aux_mes_unid = aux_mes_unid + 1>
            </cfloop>
            <tr class="exibir">
                <td colspan="7"><hr></td>
                <td>      
            </tr>
            <cfset PerDP = NumberFormat(((un_dp_soma/(un_dp_soma + un_fp_soma))* 100),999.0)> 
            <cfset PerFP = NumberFormat(((un_fp_soma/(un_dp_soma + un_fp_soma))* 100),999.0)>    	          
            <tr class="tituloC">
                <td class="red_titulo"><div align="center"><strong>Total</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#un_dp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#PerDP#</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#un_fp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center">#PerFP#</div></td>
                <td class="red_titulo"><div align="center"><strong>#(un_dp_soma + un_fp_soma)#</strong></div></td>
                <td class="red_titulo"><div align="center"><span class="titulos"><button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'un',0,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar(Todos)</button></span></div></td>
                <td class="red_titulo"></td>
            </tr>
        </cfif>		

        <!--- AREAS --->		
        <cfif totmesgeDPFP neq 0>
            <cfif aux_mes eq 1>
                <tr class="exibir">
                <td colspan="7" class="titulos"><hr></td>
                </tr>
                <tr class="exibir">
                    <td colspan="7" class="titulos"><div align="center"> <strong>Gerências Regionais e Áreas de Suporte</strong> </div></td>
                </tr>
                <tr class="exibir">
                    <td><div align="center"><strong>Mês</strong></div></td>
                    <td><div align="center"><strong>Dentro prazo</strong></div></td>
                    <td><div align="center">%(DP)</div></td>
                    <td><div align="center"><strong>Fora prazo</strong></div></td>
                    <td><div align="center">%(FP)</div></td>
                    <td><div align="center"><strong>Total</strong></div></td>
                    <td>&nbsp;</td>
                    <td width="1%"></td>       
                </tr>
            </cfif>      
            <cfset aux_mes_ge = 1>
            <cfset ge_dp_soma = 0>
	        <cfset ge_fp_soma = 0>
            <cfloop condition="aux_mes_ge lte month(dtlimit)">
                <!--- quant. (DP + FP) --->
                <cfquery dbtype="query" name="rstotmesgeDPFP">
                    SELECT Andt_Prazo 
                    FROM  rsBaseB
                    where Andt_Resp in (6,5,19) and Andt_Mes = #aux_mes_ge#
                </cfquery>                    
                <cfset totmesgeDPFP = rstotmesgeDPFP.recordcount>
                <!--- quant. DP --->
                <cfquery dbtype="query" name="rstotmesgeDP">
                    SELECT Andt_Prazo 
                    FROM  rsBaseB
                    where Andt_Resp in (6,5,19) and Andt_Prazo = 'DP' and Andt_Mes = #aux_mes_ge#
                </cfquery>    
                <cfset totmesgeDP = rstotmesgeDP.recordcount>
                <!--- Quant. FP --->
                <cfset totmesgeFP = (totmesgeDPFP - totmesgeDP)>

                <cfif aux_mes_ge is 1>
                    <cfset mestext = 'JAN'>
                    <cfset totjanDP = totjanDP + totmesgeDP>
                    <cfset totjanFP = totjanFP + totmesgeFP>
                <cfelseif aux_mes_ge is 2>  
                    <cfset mestext = 'FEV'>   
                    <cfset totfevDP = totfevDP + totmesgeDP>
                    <cfset totfevFP = totfevFP + totmesgeFP>                              
                <cfelseif aux_mes_ge is 3>
                    <cfset mestext = 'MAR'>   
                    <cfset totmarDP = totmarDP + totmesgeDP>
                    <cfset totmarFP = totmarFP + totmesgeFP>                                   
                <cfelseif aux_mes_ge is 4>
                    <cfset mestext = 'ABR'>	                	
                    <cfset totabrDP = totabrDP + totmesgeDP>
                    <cfset totabrFP = totabrFP + totmesgeFP>                      
                <cfelseif aux_mes_ge is 5>
                    <cfset mestext = 'MAI'>	      
                    <cfset totmaiDP = totmaiDP + totmesgeDP>
                    <cfset totmaiFP = totmaiFP + totmesgeFP>                                  	
                <cfelseif aux_mes_ge is 6>
                    <cfset mestext = 'JUN'>	                    
                    <cfset totjunDP = totjunDP + totmesgeDP>
                    <cfset totjunFP = totjunFP + totmesgeFP>                       			   
                <cfelseif aux_mes_ge is 7>
                    <cfset mestext = 'JUL'>		                  
                    <cfset totjulDP = totjulDP + totmesgeDP>
                    <cfset totjulFP = totjulFP + totmesgeFP>                       		   
                <cfelseif aux_mes_ge is 8>
                    <cfset mestext = 'AGO'>			               	
                    <cfset totagoDP = totagoDP + totmesgeDP>
                    <cfset totagoFP = totagoFP + totmesgeFP>                         
                <cfelseif aux_mes_ge is 9>
                    <cfset mestext = 'SET'>			                
                    <cfset totsetDP = totsetDP + totmesgeDP>
                    <cfset totsetFP = totsetFP + totmesgeFP>                        	   
                <cfelseif aux_mes_ge is 10>
                    <cfset mestext = 'OUT'>                 
                    <cfset totoutDP = totoutDP + totmesgeDP>
                    <cfset totoutFP = totoutFP + totmesgeFP>                      
                <cfelseif aux_mes_ge is 11>	
                    <cfset mestext = 'NOV'>	   		              
                    <cfset totnovDP = totnovDP + totmesgeDP>
                    <cfset totnovFP = totnovFP + totmesgeFP>                           		   
                <cfelse>
                    <cfset mestext = 'DEZ'>		
                    <cfset totdezDP = totdezDP + totmesgeDP>
                    <cfset totdezFP = totdezFP + totmesgeFP>                      	                   	   
                </cfif> 
                <cfif totmesgeDPFP gt 0>
                <cfset PerDP = NumberFormat(((totmesgeDP/totmesgeDPFP)* 100),999.0)> 
                <cfset PerFP = NumberFormat(((totmesgeFP/totmesgeDPFP)* 100),999.0)>                               
                    <tr class="exibir">
                        <td><div align="center"><strong>#mestext#</strong></div></td>
                        <td><div align="center"><strong>#totmesgeDP#</strong></div></td>
                        <td><div align="center">#PerDP#</div></td>
                        <td><div align="center"><strong>#totmesgeFP#</strong></div></td>
                        <td><div align="center" class="red_titulo">#PerFP#</div></td>
                        <td><div align="center"><strong>#totmesgeDPFP#</strong></div></td>
                        <td width="13%" class="exibir"><div align="center"><button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge','#aux_mes_ge#',<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button></div><td>
                    </tr>
                    <cfset ge_dp_soma = ge_dp_soma + totmesgeDP>
                    <cfset ge_fp_soma = ge_fp_soma + totmesgeFP>
                </cfif>
                <cfset aux_mes_ge = aux_mes_ge + 1>
            </cfloop>
            <tr class="exibir">
                <td colspan="7"><hr></td>
                <td>      
            </tr>
            <cfif totmesgeDPFP gt 0>
                <cfset PerDP = NumberFormat((ge_dp_soma/(ge_dp_soma + ge_fp_soma)* 100),999.0)> 
                <cfset PerFP = NumberFormat((ge_fp_soma/(ge_dp_soma + ge_fp_soma)* 100),999.0)>  
            </cfif>	
            <tr class="tituloC">
                <td class="red_titulo"><div align="center"><strong>Total</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#ge_dp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#PerDP#</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#ge_fp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center">#PerFP#</div></td>
                <td class="red_titulo"><div align="center"><strong>#ge_dp_soma + ge_fp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center"><span class="titulos"><button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',0,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar(Todos)</button></span></div></td>
                <td class="red_titulo"></td>
            </tr>
        </cfif>		

        <!--- SUBORDINADORES --->		
        <cfif totmessbDPFP neq 0>
            <cfif aux_mes eq 1>
                <tr class="exibir">
                <td colspan="7" class="titulos"><hr></td>
                </tr>
                <tr class="exibir">
                    <td colspan="7" class="titulos"><div align="center">Órgãos Subordinadores</div></td>
                </tr>
                <tr class="exibir">
                <td><div align="center"><strong>Mês</strong></div></td>
                <td><div align="center"><strong>Dentro prazo</strong></div></td>
                <td><div align="center">%(DP)</div></td>
                <td><div align="center"><strong>Fora prazo</strong></div></td>
                <td><div align="center">%(FP)</div></td>
                <td><div align="center"><strong>Total</strong></div></td>
                <td>&nbsp;</td>
                <td width="1%"></td>    
                </tr>
            </cfif>
            <cfset aux_mes_sb = 1>
            <cfset sb_dp_soma = 0>
	        <cfset sb_fp_soma = 0>
            <cfloop condition="aux_mes_sb lte month(dtlimit)">
                <!--- quant. (DP + FP) --->
                <cfquery dbtype="query" name="rstotmessbDPFP">
                    SELECT Andt_Prazo 
                    FROM  rsBaseB
                    where Andt_Resp in (4,7,16) and Andt_Mes = #aux_mes_sb#
                </cfquery>
                <cfset totmessbDPFP = rstotmessbDPFP.recordcount>

                <!--- quant. DP --->
                <cfquery dbtype="query" name="rstotmessbDP">
                    SELECT Andt_Prazo 
                    FROM  rsBaseB
                    where Andt_Resp in (4,7,16) and Andt_Prazo = 'DP' and Andt_Mes = #aux_mes_sb#
                </cfquery>    
                <cfset totmessbDP = rstotmessbDP.recordcount>

                <!--- Quant. FP --->
                <cfset totmessbFP = (totmessbDPFP - totmessbDP)>

                <cfif aux_mes_sb is 1>
                    <cfset mestext = 'JAN'>
                    <cfset totjanDP = totjanDP + totmessbDP>
                    <cfset totjanFP = totjanFP + totmessbFP>
                <cfelseif aux_mes_sb is 2>  
                    <cfset mestext = 'FEV'>   
                    <cfset totfevDP = totfevDP + totmessbDP>
                    <cfset totfevFP = totfevFP + totmessbFP>                              
                <cfelseif aux_mes_sb is 3>
                    <cfset mestext = 'MAR'>   
                    <cfset totmarDP = totmarDP + totmessbDP>
                    <cfset totmarFP = totmarFP + totmessbFP>                                   
                <cfelseif aux_mes_sb is 4>
                    <cfset mestext = 'ABR'>	                	
                    <cfset totabrDP = totabrDP + totmessbDP>
                    <cfset totabrFP = totabrFP + totmessbFP>                      
                <cfelseif aux_mes_sb is 5>
                    <cfset mestext = 'MAI'>	      
                    <cfset totmaiDP = totmaiDP + totmessbDP>
                    <cfset totmaiFP = totmaiFP + totmessbFP>                                  	
                <cfelseif aux_mes_sb is 6>
                    <cfset mestext = 'JUN'>	                    
                    <cfset totjunDP = totjunDP + totmessbDP>
                    <cfset totjunFP = totjunFP + totmessbFP>                       			   
                <cfelseif aux_mes_sb is 7>
                    <cfset mestext = 'JUL'>		                  
                    <cfset totjulDP = totjulDP + totmessbDP>
                    <cfset totjulFP = totjulFP + totmessbFP>                       		   
                <cfelseif aux_mes_sb is 8>
                    <cfset mestext = 'AGO'>			               	
                    <cfset totagoDP = totagoDP + totmessbDP>
                    <cfset totagoFP = totagoFP + totmessbFP>                         
                <cfelseif aux_mes_sb is 9>
                    <cfset mestext = 'SET'>			                
                    <cfset totsetDP = totsetDP + totmessbDP>
                    <cfset totsetFP = totsetFP + totmessbFP>                        	   
                <cfelseif aux_mes_sb is 10>
                    <cfset mestext = 'OUT'>                 
                    <cfset totoutDP = totoutDP + totmessbDP>
                    <cfset totoutFP = totoutFP + totmessbFP>                      
                <cfelseif aux_mes_sb is 11>	
                    <cfset mestext = 'NOV'>	   		              
                    <cfset totnovDP = totnovDP + totmessbDP>
                    <cfset totnovFP = totnovFP + totmessbFP>                           		   
                <cfelse>
                    <cfset mestext = 'DEZ'>		
                    <cfset totdezDP = totdezDP + totmessbDP>
                    <cfset totdezFP = totdezFP + totmessbFP>                      	                   	   
                </cfif> 

                <cfif totmessbDPFP gt 0>    
                    <cfset PerFP = NumberFormat(((totmessbFP/totmessbDPFP)* 100),999.0)>   
                    <cfset PerDP = NumberFormat(((totmessbDP/totmessbDPFP)* 100),999.0)>                                                        
                    <tr class="exibir">
                        <td><div align="center"><strong>#mestext#</strong></div></td>
                        <td><div align="center"><strong>#totmessbDP#</strong></div></td>
                        <td><div align="center">#PerDP#</div></td>
                        <td><div align="center"><strong>#totmessbFP#</strong></div></td>
                        <td><div align="center" class="red_titulo">#PerFP#</div></td>
                        <td><div align="center"><strong>#totmessbDPFP#</strong></div></td>
                        <td width="13%" class="exibir"><div align="center"><button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb','#aux_mes_sb#',<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button></div><td>
                    </tr>
                    <cfset sb_dp_soma = sb_dp_soma + totmessbDP>
                    <cfset sb_fp_soma = sb_fp_soma + totmessbFP>
                </cfif>
                <cfset aux_mes_sb = aux_mes_sb + 1>              
            </cfloop>
            <tr class="exibir">
                <td colspan="7"><hr></td>
                <td>      
            </tr> 
            <cfif totmessbDPFP gt 0>     
                <cfset PerDP = NumberFormat(((sb_dp_soma/(sb_dp_soma + sb_fp_soma))* 100),999.0)>   
                <cfset PerFP = NumberFormat(((sb_fp_soma/(sb_dp_soma + sb_fp_soma))* 100),999.0)>                                
            </cfif>           
            <tr class="tituloC">
                <td class="red_titulo"><div align="center"><strong>Total</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#sb_dp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#PerDP#</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#sb_fp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center">#PerFP#</div></td>
                <td class="red_titulo"><div align="center"><strong>#sb_dp_soma + sb_fp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center"><span class="titulos"><button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',0,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar(Todos)</button></span></div></td>
                <td class="red_titulo"></td>
            </tr>

        </cfif>	

        <!--- SUPERINTENDENTES --->	
        <cfif totmessuDPFP neq 0>
            <cfif aux_mes eq 1>
                <tr class="exibir">
                <td colspan="7" class="titulos"><hr></td>
                </tr>
                <tr class="exibir">
                    <td colspan="7" class="titulos"><div align="center">Superintendência</div></td>
                </tr>
                <tr class="exibir">
                <td><div align="center"><strong>Mês</strong></div></td>
                <td><div align="center"><strong>Dentro prazo</strong></div></td>
                <td><div align="center">%(DP)</div></td>
                <td><div align="center"><strong>Fora prazo</strong></div></td>
                <td><div align="center">%(FP)</div></td>
                <td><div align="center"><strong>Total</strong></div></td>
                <td>&nbsp;</td>
                <td width="1%"></td>    
                </tr>
            </cfif>
            <cfset aux_mes_su = 1>
            <cfset su_dp_soma = 0>
	        <cfset su_fp_soma = 0>
            <cfloop condition="aux_mes_su lte month(dtlimit)">
                <!--- quant. (DP + FP) --->
                <cfquery dbtype="query" name="rstotmessuDPFP">
                    SELECT Andt_Prazo 
                    FROM  rsBaseB
                    where Andt_Resp in (8,22,23) and Andt_Mes = #aux_mes_su#
                </cfquery>
                <cfset totmessuDPFP = rstotmessuDPFP.recordcount> 

                <!--- quant. DP --->
                <cfquery dbtype="query" name="rstotmessuDP">
                    SELECT Andt_Prazo 
                    FROM  rsBaseB
                    where Andt_Resp in (8,22,23) and Andt_Prazo = 'DP' and Andt_Mes = #aux_mes_su#
                </cfquery>    
                <cfset totmessuDP = rstotmessuDP.recordcount>
                <!--- Quant. FP --->
                <cfset totmessuFP = (totmessuDPFP - totmessuDP)>

                <cfif aux_mes_su is 1>
                    <cfset mestext = 'JAN'>
                    <cfset totjanDP = totjanDP + totmessuDP>
                    <cfset totjanFP = totjanFP + totmessuFP>
                <cfelseif aux_mes_su is 2>  
                    <cfset mestext = 'FEV'>   
                    <cfset totfevDP = totfevDP + totmessuDP>
                    <cfset totfevFP = totfevFP + totmessuFP>                              
                <cfelseif aux_mes_su is 3>
                    <cfset mestext = 'MAR'>   
                    <cfset totmarDP = totmarDP + totmessuDP>
                    <cfset totmarFP = totmarFP + totmessuFP>                                   
                <cfelseif aux_mes_su is 4>
                    <cfset mestext = 'ABR'>	                	
                    <cfset totabrDP = totabrDP + totmessuDP>
                    <cfset totabrFP = totabrFP + totmessuFP>                      
                <cfelseif aux_mes_su is 5>
                    <cfset mestext = 'MAI'>	      
                    <cfset totmaiDP = totmaiDP + totmessuDP>
                    <cfset totmaiFP = totmaiFP + totmessuFP>                                  	
                <cfelseif aux_mes_su is 6>
                    <cfset mestext = 'JUN'>	                    
                    <cfset totjunDP = totjunDP + totmessuDP>
                    <cfset totjunFP = totjunFP + totmessuFP>                       			   
                <cfelseif aux_mes_su is 7>
                    <cfset mestext = 'JUL'>		                  
                    <cfset totjulDP = totjulDP + totmessuDP>
                    <cfset totjulFP = totjulFP + totmessuFP>                       		   
                <cfelseif aux_mes_su is 8>
                    <cfset mestext = 'AGO'>			               	
                    <cfset totagoDP = totagoDP + totmessuDP>
                    <cfset totagoFP = totagoFP + totmessuFP>                         
                <cfelseif aux_mes_su is 9>
                    <cfset mestext = 'SET'>			                
                    <cfset totsetDP = totsetDP + totmessuDP>
                    <cfset totsetFP = totsetFP + totmessuFP>                        	   
                <cfelseif aux_mes_su is 10>
                    <cfset mestext = 'OUT'>                 
                    <cfset totoutDP = totoutDP + totmessuDP>
                    <cfset totoutFP = totoutFP + totmessuFP>                      
                <cfelseif aux_mes_su is 11>	
                    <cfset mestext = 'NOV'>	   		              
                    <cfset totnovDP = totnovDP + totmessuDP>
                    <cfset totnovFP = totnovFP + totmessuFP>                           		   
                <cfelse>
                    <cfset mestext = 'DEZ'>		
                    <cfset totdezDP = totdezDP + totmessuDP>
                    <cfset totdezFP = totdezFP + totmessuFP>                      	                   	   
                </cfif> 

                <cfif totmessuDPFP gt 0>                 
                    <cfset PerFP = NumberFormat(((totmessuFP/totmessuDPFP)* 100),999.0)>   
                    <cfset PerDP = NumberFormat(((totmessuDP/totmessuDPFP)* 100),999.0)>                     
                    <tr class="exibir">
                        <td><div align="center"><strong>#mestext#</strong></div></td>
                        <td><div align="center"><strong>#totmessuDP#</strong></div></td>
                        <td><div align="center">#PerDP#</div></td>
                        <td><div align="center"><strong>#totmessuFP#</strong></div></td>
                        <td><div align="center" class="red_titulo">#PerFP#</div></td>
                        <td><div align="center"><strong>#totmessuDPFP#</strong></div></td>
                        <td width="13%" class="exibir"><div align="center"><button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su','#aux_mes_su#',<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button></div><td>
                    </tr>
                    <cfset su_dp_soma = su_dp_soma + totmessuDP>
                    <cfset su_fp_soma = su_fp_soma + totmessuFP>
                </cfif>                 
                <cfset aux_mes_su = aux_mes_su + 1>
            </cfloop>
            <tr class="exibir">
                <td colspan="7"><hr></td>
                <td>      
            </tr>
            <cfif totmessuDPFP gt 0>                             
                <cfset PerFP = NumberFormat((su_fp_soma/(su_dp_soma + su_fp_soma)* 100),999.0)>   
                <cfset PerDP = NumberFormat((su_dp_soma/(su_dp_soma + su_fp_soma)* 100),999.0)>   
            </cfif>	
            <tr class="tituloC">
                <td class="red_titulo"><div align="center"><strong>Total</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#su_dp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#PerDP#</strong></div></td>
                <td class="red_titulo"><div align="center"><strong>#su_fp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center">#PerFP#</div></td>
                <td class="red_titulo"><div align="center"><strong>#su_dp_soma + su_fp_soma#</strong></div></td>
                <td class="red_titulo"><div align="center"><span class="titulos"><button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'su',0,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar(Todos)</button></span></div></td>
                <td class="red_titulo"></td>
            </tr>
        </cfif>	        
      <tr class="exibir">
        <td colspan="7" class="titulos">&nbsp;</td>
      </tr>
  </table>

<cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT top 1 Met_Codigo,Met_Ano, Met_Mes,Met_SE_STO,Met_SLNC,Met_PRCI,Met_DGCI,Met_SLNC_Acum,Met_PRCI_Acum
	FROM Metas
	WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)#
</cfquery>

<cfset metames = trim(rsMetas.Met_PRCI)> 
<!---  --->
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
<cffile action="Append" file="#slocal##sarquivo#" output='Atendimento ao Prazo de Resposta do Controle Interno (PRCI)'>
<cffile action="Append" file="#slocal##sarquivo#" output=';;A;B;C;D;E;F;G = ((B * 100)/F);'>

<cffile action="Append" file="#slocal##sarquivo#" output='SE;MÊS;DENTROPRAZO;%(DP);FORAPRAZO;%(FP);TOTAL;METAMENSAL(%);RESULTADOEMRELAÇÃOÀMETA;RESULTADO'>
<!---  --->

<table width="59%" border="1" align="center" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="13"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="45" height="45" border="0"></a></div></td>
</tr>
  <tr>
    <td colspan="17" class="exibir"><div align="center"> <strong> Atendimento ao Prazo de Resposta do Controle Interno (PRCI)</strong></div></td>
  </tr>

  <tr class="exibir">
      <td width="3%" valign="middle"><div align="center">&nbsp;</div></td>
      <td width="4%" valign="middle"><div align="center">&nbsp;</div></td>
      <td class="exibir"><div align="center">A</div></td>
      <td class="exibir"><div align="center">B</div></td>
      <td class="exibir"><div align="center">C</div></td>
      <td class="exibir"><div align="center">D</div></td>
      <td class="exibir"><div align="center">E</div></td>
      <td class="exibir"><div align="center">F</div></td>
      <td class="exibir"><div align="center">G = ((B * 100)/F) </div></td>
      <td class="exibir">&nbsp;</td>
  </tr>

  <cfset auxsigl = qAcesso.Dir_Sigla>
  <tr class="exibir">
    <td width="3%" valign="middle"><div align="center"><strong>SE</strong></div></td>
    <td width="4%" valign="middle"><div align="center"><strong>MÊS</strong></div></td>
    <td class="exibir"><div align="center"><strong>DENTRO DO PRAZO(DP)</strong></div>      <div align="center"></div>      <div align="center"></div></td>
    <td class="exibir"><div align="center">%(DP)</div></td>
    <td class="exibir"><div align="center"><strong> FORA DO PRAZO(FP)</strong></div>      
      <div align="center"></div>      <div align="center"></div>      <div align="center"></div></td>
    <td class="exibir"><div align="center">%(FP)</div></td>
    <td width="9%" class="exibir"><div align="center"></div>      <div align="center"><strong>TOTAL</strong></div></td>
    <td width="12%" class="exibir"><div align="center"><strong>META MENSAL (%)</strong> </div></td>
    <td width="14%" class="exibir"><div align="center"><strong>RESULTADO EM RELAÇÃO À META (%)</strong></div></td>
    <td width="15%" class="exibir"><div align="center"><strong>RESULTADO</strong> </div></td>
  </tr>
    <tr class="exibir">
      <td colspan="17" valign="middle"><div align="center" class="titulos"></div>        <div align="center" class="titulos"></div>        <div align="center" class="titulos"></div></td>
      </tr>
<!--- JAN --->
 <cfif (totjanDP gt 0 or totjanFP gt 0)>
  <cfset siglames = 'JAN'>
  <cfset TOTMES_DP = totjanDP>
  <cfset TOTMES_FP = totjanFP>

	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>	
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>
    <td><div align="center"><strong>JAN</strong></div></td>
    <td width="12%" class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td width="8%" class="exibir"><div align="center">#PerDP#</div></td>
    <td width="15%" class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td width="8%" class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
		<cfset ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
    <cfif PerDP gt metames>
      <cfset resultado = "ACIMA DO ESPERADO">
      <cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
      <cfset resultado = "DENTRO DO ESPERADO">
      <cfset auxcor = "##339900">
    <cfelse>
      <cfset resultado = "ABAIXO DO ESPERADO">
      <cfset auxcor = "##FF3300">
    </cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;JAN;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>
 </cfif>

<!--- FEV --->
<cfif (totfevDP gt 0 or totfevFP gt 0)>
  <cfset siglames = 'FEV'>
  <cfset TOTMES_DP = totfevDP>
  <cfset TOTMES_FP = totfevFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>

  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>
    <td><div align="center"><strong>FEV</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<cfset ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;FEV;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>
 </cfif>
<!--- MAR --->
 <cfif (totmarDP gt 0 or totmarFP gt 0)>
   <cfset siglames = 'MAR'>
  <cfset TOTMES_DP = totmarDP>
  <cfset TOTMES_FP = totmarFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>

  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>
	<td><div align="center"><strong>MAR</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;MAR;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>
 </cfif>
<!--- ABR --->
 <cfif (totabrDP gt 0 or totabrFP gt 0)>
  <cfset siglames = 'ABR'> 
  <cfset TOTMES_DP = totabrDP>
  <cfset TOTMES_FP = totabrFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
 
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>ABR</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;ABR;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>  
 </cfif> 
<!--- MAI --->
 <cfif (totmaiDP gt 0 or totmaiFP gt 0)>
  <cfset siglames = 'MAI'> 
  <cfset TOTMES_DP = totmaiDP>
  <cfset TOTMES_FP = totmaiFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
 
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>MAI</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
  <cfif #frmano# eq 2024 and #se# eq '64'>
    <cfset resultado = "SUSPENSO">
    <cfset auxcor = "">
    <cfset totmaiDP=0>
    <cfset totmaiFP=0>
  </cfif>
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;MAI;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>
 </cfif>  
<!--- JUN --->
 <cfif (totjunDP gt 0 or totjunFP gt 0)>
  <cfset siglames = 'JUN'> 
  <cfset TOTMES_DP = totjunDP>
  <cfset TOTMES_FP = totjunFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>

  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>JUN</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
  <cfif #frmano# eq 2024 and #se# eq '64'>
    <cfset resultado = "SUSPENSO">
    <cfset auxcor = "">
    <cfset totjunDP=0>
    <cfset totjunFP=0>
  </cfif>  
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;JUN;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>  
 </cfif> 
 <!--- JUL --->	
 <cfif (totjulDP gt 0 or totjulFP gt 0)>
  <cfset siglames = 'JUL'> 
  <cfset TOTMES_DP = totjulDP>
  <cfset TOTMES_FP = totjulFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>

  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>JUL</strong></div></td>
    <td width="12%" class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td width="8%" class="exibir"><div align="center">#PerDP#</div></td>
    <td width="15%" class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td width="8%" class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
  <cfif #frmano# eq 2024 and #se# eq '64'>
    <cfset resultado = "SUSPENSO">
    <cfset auxcor = "">
    <cfset totjulDP=0>
    <cfset totjulFP=0>
  </cfif>  
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;JUL;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>  
 </cfif>
<!--- AGO --->
 <cfif (totagoDP gt 0 or totagoFP gt 0)>
  <cfset siglames = 'AGO'> 
  <cfset TOTMES_DP = totagoDP>
  <cfset TOTMES_FP = totagoFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
 
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>AGO</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
  <cfif #frmano# eq 2024 and #se# eq '64'>
    <cfset resultado = "SUSPENSO">
    <cfset auxcor = "">
    <cfset totagoDP=0>
    <cfset totagoFP=0>
  </cfif>  
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;AGO;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>  
 </cfif>
<!--- SET --->
 <cfif (totsetDP gt 0 or totsetFP gt 0)>
  <cfset siglames = 'SET'> 
  <cfset TOTMES_DP = totsetDP>
  <cfset TOTMES_FP = totsetFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
 
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>SET</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <cfif #frmano# eq 2024 and #se# eq '64'>
    <cfset resultado = "SUSPENSO">
    <cfset auxcor = "">
    <cfset totsetDP=0>
    <cfset totsetFP=0>
  </cfif>
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;SET;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>    
 </cfif> 
<!--- OUT --->
 <cfif (totoutDP gt 0 or totoutFP gt 0)>
  <cfset siglames = 'OUT'> 
  <cfset TOTMES_DP = totoutDP>
  <cfset TOTMES_FP = totoutFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>OUT</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
  <cfif #frmano# eq 2024 and #se# eq '64'>
    <cfset resultado = "SUSPENSO">
    <cfset auxcor = "">
    <cfset totoutDP=0>
    <cfset totoutFP=0>
  </cfif>  
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;OUT;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>    
 </cfif> 
<!--- NOV --->
 <cfif (totnovDP gt 0 or totnovFP gt 0)>
  <cfset siglames = 'NOV'> 
  <cfset TOTMES_DP = totnovDP>
  <cfset TOTMES_FP = totnovFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>

  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>NOV</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
  <cfif #frmano# eq 2024 and #se# eq '64'>
    <cfset resultado = "SUSPENSO">
    <cfset auxcor = "">
    <cfset totnovDP=0>
    <cfset totnovFP=0>
  </cfif>  
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;NOV;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>    
 </cfif>  
<!--- DEZ --->
 <cfif (totdezDP gt 0 or totdezFP gt 0)>
  <cfset siglames = 'DEZ'> 
  <cfset TOTMES_DP = totdezDP>
  <cfset TOTMES_FP = totdezFP>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
 
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>DEZ</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
  <cfif #frmano# eq 2024 and #se# eq '64'>
    <cfset resultado = "SUSPENSO">
    <cfset auxcor = "">
    <cfset totdezDP=0>
    <cfset totdezFP=0>
  </cfif>  
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;DEZ;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>    
 </cfif>    
   <!--- Imprimir em tela o acumulado --->
     <!--- tabela final --->
  <cfset totgerDP = totjanDP + totfevDP + totmarDP + totabrDP + totmaiDP + totjunDP + totjulDP + totagoDP + totsetDP + totoutDP + totnovDP + totdezDP>
  <cfset totgerFP = totjanFP + totfevFP + totmarFP + totabrFP + totmaiFP + totjunFP + totjulFP + totagoFP + totsetFP + totoutFP + totnovFP + totdezFP>
  <cfset TOTGER = totgerDP + totgerFP>
  <cfset PerDP = numberFormat((totgerDP/(TOTGER)) * 100,999.0)>	
  <cfset PerFP = numberFormat((totgerFP/(TOTGER)) * 100,999.0)>
<!---  --->
  <tr class="titulos">
    <td><div align="center" class="red_titulo"><strong>#auxsigl#</strong></div></td>  
    <td class="red_titulo"><div align="left"><strong>Geral</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#totgerDP#</strong></div></td>
    <td><div align="center" class="red_titulo">#PerDP#</div></td>
    <td><div align="center" class="red_titulo"><strong>#totgerFP#</strong></div></td>
    <td><div align="center" class="red_titulo">#PerFP#</div></td>
    <td><div align="center" class="red_titulo"><strong>#TOTGER#</strong></div></td>
    <td class="exibir"><div align="center" class="red_titulo"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center" class="red_titulo">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
  <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;Geral;#totgerDP#;#PerDP#;#totgerFP#;#PerFP#;#TOTGER#;#metames#;#ResultMeta#;#resultado#'>
  <tr class="exibir">
    <td colspan="10"><strong>Legenda:</strong></td>
  </tr>

  <tr class="exibir">
    <td colspan="10"><strong> * TOTAL (E) - É o somatório dos itens respondidos (Dentro do Prazo (DP) + Fora do Prazo (FP))</strong></td>
  </tr>
  <tr class="exibir">
    <td colspan="10"><strong> ** %DP (B) =(( A/E) * 100</strong>) </td>
  </tr>
  <tr class="exibir">
    <td colspan="10"><strong> *** Resultado em Relação à Meta (G) = ((B * 100)/F)</strong> </td>
  </tr>
  <tr class="exibir">
    <td colspan="10"><strong> DP = Dentro do Prazo</strong> </td>
  </tr>
<cfif frmano eq anoatual>
  <cfset dtini = dateformat(now(),"DD/MM/YYYY")>
  <cfset dtini = '01' & right(dtini,8)>
  <cfset dtfim = now()>
  <cfset dtfim = DateAdd( "d", -1, dtfim)>
    <tr class="exibir">
      <td colspan="18" class="exibir"><strong>#siglames#&nbsp;&nbsp;&nbsp;Período de  #dtini#  até  #dateformat(dtfim,"DD/MM/YYYY")#</strong></td>
    </tr> 
</cfif>      
</table>
<cffile action="Append" file="#slocal##sarquivo#" output='Legenda:'>
<cffile action="Append" file="#slocal##sarquivo#" output='* Total (E) - É o somatório dos itens respondidos Dentro do Prazo (DP) + Fora do Prazo (FP)'>
<cffile action="Append" file="#slocal##sarquivo#" output='** %DP (B) = ((A/E) * 100)'>
<cffile action="Append" file="#slocal##sarquivo#" output='*** Resultado em Relação à Meta (G) = ((B * 100)/F'>
<cffile action="Append" file="#slocal##sarquivo#" output='DP = Dentro do Prazo'>
<cfif frmano eq anoatual>
  <cffile action="Append" file="#slocal##sarquivo#" output='#siglames#&nbsp;&nbsp;&nbsp;Período de  #dtini#  até  #dateformat(dtfim,"DD/MM/YYYY")#'>
</cfif>

<input name="se" type="hidden" value="#se#">


<!--- fim exibicao --->
</form>
<form name="formx" method="POST" action="prci1.cfm" target="_blank">
	<input name="lis_se" type="hidden" value="#se#">
	<input name="lis_mes" type="hidden" value="">
	<input name="lis_grpace" type="hidden" value="">
	<input name="lis_ano" type="hidden" value="">
</form>
  <cfinclude template="rodape.cfm">
 </cfoutput> 
</body>
</html>