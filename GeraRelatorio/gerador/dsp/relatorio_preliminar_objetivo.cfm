<cftry>
<cfinclude template="../../../parametros.cfm">

 <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller" 
	method="geraMatriculaData" returnvariable="qryInspetor">
	
</cfinvoke> 

<cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller" 
	method="geraRelatoriodata" returnvariable="qryRelatorio"></cfinvoke>
	
<cfset qtItens = qryRelatorio.recordcount>
	
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="file://///spe0034/intranet/sistemas/sarin/css.css" rel="stylesheet" type="text/css" />
<script>
// Função imprimir
function imprimir() {
    var quant = document.forms[0].elements.length;
      for(var i = 0; i < quant; i++){
        if (document.forms[0].elements[i].type == 'button' || document.forms[0].elements[i].type == 'submit') {
          document.forms[0].elements[i].style.visibility='hidden';
        }
      }
      for(var x = 0; x < <cfoutput>#qtItens#</cfoutput>; x++){   
        window.anexo[x].style.visibility = 'hidden';
      }
	  for(var x = 0; x < <cfoutput>#qtItens#</cfoutput>; x++){   
        window.arquivo[x].style.visibility = 'hidden';
      }
      print();
      for(var i = 0; i < quant; i++){
        if (document.forms[0].elements[i].type == 'button' || document.forms[0].elements[i].type == 'submit') {
          document.forms[0].elements[i].style.visibility='visible';
        }
      }
     for(var x = 0; x < <cfoutput>#qtItens#</cfoutput>; x++){   
        window.anexo[x].style.visibility = 'visible';
      }
	  
	  for(var x = 0; x < <cfoutput>#qtItens#</cfoutput>; x++){   
        window.arquivo[x].style.visibility = 'visible';
      }
}
</script>


<style type="text/css"> 
<!--
.style2 {
	font-size: 20px;
	font-weight: bold;
}
-->
</style>
</head>

<body>
<form>
<table border="0" width="95%">
 <cfif qryRelatorio.recordcount is 0>
    <tr>    
      <td  valign="baseline" bordercolor="999999" bgcolor="F5F5F5" class="red_titulo"><div align="center"><span class="style2">Caro colaborador não há registros para o per&iacute;odo solicitado</span>.</div></td>    
    </tr>
    </table>
   <cfabort>
 </cfif>

  <tr>
    <th width="22%" rowspan="2"><div align="left"><img src="file://///spe0034/intranet/sistemas/sarin/GeraRelatorio/geral/img/logoCorreios.gif" alt="Logo ECT" width="177" height="43" align="left" /></div></th>
    <td width="80%" class="labelcell"><span class="style2">Ger&ecirc;ncia de Macrorregi&atilde;o de Auditoria</span></td>
  </tr>  
  <tr>
    <td height="30%" class="labelcell"><p class="style2">Relat&oacute;rio Preliminar de Auditoria por Objetivo </p>
    </td>
  </tr>
</table>
  <table width="95%" border="0" cellspacing="4">
  <tr>
    <th colspan="5" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
  </tr>
  <tr>
    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</td>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Tipo de Unidade: </div></th>	
	<cfif Trim(UCASE(Tipo)) is ''> 
      <td colspan="3" bgcolor="F5F5F5">Todos</td>
    <cfelse>	   
      <td width="22%" colspan="3" bgcolor="F5F5F5"><cfoutput>#qryRelatorio.TUN_Descricao#</cfoutput></td>
	</cfif>    
  </tr> 
  
  <tr>
    <th width="2%" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left" class="labelcell"></div></th>
    <th width="15%" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Diretoria:</div></th>
    <td colspan="3" bgcolor="F5F5F5"><div align="justify"><cfoutput>#DR#</cfoutput></div></td>
  </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left" class="labelcell"></div></th>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Per&iacute;odo:</div></th>
    <td colspan="3" bgcolor="F5F5F5"><div align="justify"><cfoutput>#dtini#</cfoutput>

      <label class="fieldcell"> 
      a      </label>
 <cfoutput>#dtfim#</cfoutput></div></td>
  </tr>
  
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="4" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
  </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="4" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">4. Situação Encontrada, Causas Prov&aacute;veis, Manisfesta&ccedil;&otilde;es e Recomenda&ccedil;&otilde;es</div></th>
  </tr> 
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="4" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
  </tr>
  
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left"><cfoutput>Objetivo: #qryRelatorio.Grp_Codigo#</cfoutput></div></th>	
    <td colspan="3" bgcolor="F5F5F5"><cfoutput>#qryRelatorio.Grp_Descricao#</cfoutput></td>
  </tr>     
   <cfset numGrav = 0>
   <cfset muitoGrav = 0>
   <cfset CP = 0>   

<cfoutput query="qryRelatorio" group="Itn_NumItem">  
  <tr>
    <th colspan="5" valign="top" bordercolor="999999" bgcolor="CCCCCC" scope="row">&nbsp;</th>
  </tr>  
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left" class="labelcell">
      <div align="center"></div>
    </div> </th>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Item: #Itn_NumItem#</div></th>
    <td colspan="3" bgcolor="F5F5F5"><div align="justify">#Itn_Descricao#</div></td>
  </tr>  
  <cfoutput> 
   <cfset grav = 0>
  
    <!--- Grau de risco ---> 
   <cfif qryRelatorio.Ana_Col01 is 1><cfset grav = int(10)></cfif>
   <cfif qryRelatorio.Ana_Col02 is 1><cfset grav = val(grav) + int(5)></cfif>
   <cfif qryRelatorio.Ana_Col03 is 1><cfset grav = val(grav) + int(7)></cfif>
   <cfif qryRelatorio.Ana_Col04 is 1><cfset grav = val(grav) + int(10)></cfif>
   <cfif qryRelatorio.Ana_Col05 is 1><cfset grav = val(grav) + int(5)></cfif>
   <cfif qryRelatorio.Ana_Col06 is 1><cfset grav = val(grav) + int(2)></cfif>
   <cfif qryRelatorio.Ana_Col07 is 1><cfset grav = val(grav) + int(7)></cfif>
   <cfif qryRelatorio.Ana_Col08 is 1><cfset grav = val(grav) + int(5)></cfif>
   <cfif qryRelatorio.Ana_Col09 is 1><cfset grav = val(grav) + int(10)></cfif>
 
    <cfif val(grav) gt 46>
      <cfset sGrav ="Muito Alto">  
    </cfif>
    <cfif val(grav) is 0>
      <cfset sGrav ="----">
    </cfif>
    <cfif val(grav) gt 0 and val(grav) lte 15>
      <cfset sGrav ="Baixo">
    </cfif>
    <cfif val(grav) gt 15 and val(grav) lte 31>
      <cfset sGrav ="Médio">
    </cfif>
    <cfif val(grav) gt 31 and val(grav) lte 46>
      <cfset sGrav ="Alto">   
    </cfif> 
	  
    <cfif Pos_Relevancia eq 1>
	   <cfset CP = CP + 1>
    </cfif>
    <cfif sGrav eq 'Médio' or sGrav eq 'Alto'>
	   <cfset numGrav = 1>
    </cfif>
    <cfif sGrav eq 'Muito Alto'>
	   <cfset muitoGrav = 1>
    </cfif>    
  <tr>
    <th colspan="5" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
  </tr>
  
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Unidade:</div></th>
    <td colspan="3" bgcolor="F5F5F5">#UND_descricao#</td>
  </tr>
  <cfset Num_Insp = Left(INP_NumInspecao,2) & '.' & Mid(INP_NumInspecao,3,4) & '/' & Right(INP_NumInspecao,4)>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">N&ordm; da Auditoria:</div></th>
    <td colspan="3" bgcolor="F5F5F5">#Num_Insp#</td>
  </tr>  
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Risco:</div></th>
    <td colspan="3" bgcolor="F5F5F5">#SGrav#</td>
  </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">
      <div align="left"></div>
    </div>      
    <div align="left"></div></th> 
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Situa&ccedil;&atilde;o Encontrada::</div></th>
    <td colspan="3" bgcolor="F5F5F5"><div align="justify"><cfset coment = Replace(RIP_Comentario,"
","<BR>" ,"All")>#coment#</div></td>
  </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left" class="labelcell">
        <div align="center"></div>
      </div>
     </th>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Situa&ccedil;&atilde;o:</div></th>
    <td colspan="3" bgcolor="F5F5F5"><div align="justify"><cfif qryRelatorio.Pos_Situacao_Resp eq 0>Responder
	                                                        <cfelseif qryRelatorio.Pos_Situacao_Resp eq 1>Resposta Unidade
															<cfelseif qryRelatorio.Pos_Situacao_Resp eq 2>Pendente Unidade
															<cfelseif qryRelatorio.Pos_Situacao_Resp eq 3>Solucionado
															<cfelseif qryRelatorio.Pos_Situacao_Resp eq 4>Pendente Órgão Subordinador
															<cfelseif qryRelatorio.Pos_Situacao_Resp eq 5>Pendente Área
															<cfelseif qryRelatorio.Pos_Situacao_Resp eq 6>Resposta Área
															<cfelseif qryRelatorio.Pos_Situacao_Resp eq 7>Resposta Órgão Subordinador
															<cfelseif qryRelatorio.Pos_Situacao_Resp eq 8>Corporativo DR
															<cfelseif qryRelatorio.Pos_Situacao_Resp eq 9>Corporativo AC
															</cfif>
	
	</div></td>
  </tr>  
<tr>
  <th bordercolor="999999" bgcolor="F5F5F5">&nbsp;</th>
  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller" 
	    method="geraAnexoNumero" returnvariable="qryAnexos">
		<cfinvokeargument name="vNumInspecao" value="#qryRelatorio.INP_NumInspecao#">
		<cfinvokeargument name="vNumGrupo" value="#qryRelatorio.Grp_Codigo#">
		<cfinvokeargument name="vNumItem" value="#qryRelatorio.Itn_NumItem#">
  </cfinvoke> 
  <th bordercolor="999999" bgcolor="F5F5F5"><div  id="anexo" align="left">Anexo:</div></th>
  <td colspan="3" bordercolor="999999" bgcolor="F5F5F5"><div id="arquivo">
  <cfloop query="qryAnexos">
    <a target="_blank" href="#qryAnexos.Ane_Caminho#">
	<span class="link1">#ListLast(qryAnexos.Ane_Caminho,'\')#</span><br></a>
    </cfloop>  
  </div></td>
 </tr> 
  </cfoutput> 
</cfoutput>  
  <tr>
    <th colspan="5" valign="top" bordercolor="999999" bgcolor="CCCCCC" scope="row">&nbsp;</th>
  </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="4" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Equipe:</div></th>
  </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="3" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left"></div></th>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">Assinaturas:</th>
  </tr>  
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Coordenadores:</div></th>
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
  </tr>    
	 <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller" 
	  method="geraCoordenador" returnvariable="qryCoordenadores">
	  <cfinvokeargument name="vdataini" value="#dtini#">
	  <cfinvokeargument name="vdatafim" value="#dtfim#">			
   </cfinvoke>	  
   	 	  
  <cfoutput>
    <cfloop query="qryCoordenadores"> 	  	  
     <tr>
       <td valign="top" bordercolor="999999" bgcolor="F5F5F5">&nbsp;</td>
       <th valign="top" bordercolor="999999" bgcolor="F5F5F5">&nbsp;</th>
       <td width="11%" valign="top" bordercolor="999999" bgcolor="F5F5F5"><div align="center">#(Left(INP_Coordenador,1) & '.' & Mid(INP_Coordenador,2,3) & '.' & Mid(INP_Coordenador,5,3) & '-' & Right(INP_Coordenador,1))#</div></td>
       <td width="31%" valign="top" bordercolor="999999" bgcolor="F5F5F5">#Fun_Nome#</td>
       <td valign="top" bordercolor="999999" bgcolor="F5F5F5"> <div align="center">----------------------------</div></td>
     </tr>
    </cfloop>
  </cfoutput> 
      <tr>
       <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
       <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Analistas:</div></th>
       <th colspan="3" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>	   
      </tr> 
     
  
 
   <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller" 
	  method="geraInspetor" returnvariable="qryInspetores">
	  <cfinvokeargument name="vdataini" value="#dtini#">
	  <cfinvokeargument name="vdatafim" value="#dtfim#">			
   </cfinvoke>	  
   	 	  
  <cfoutput>
    <cfloop query="qryInspetores"> 	  	  
     <tr>
       <td valign="top" bordercolor="999999" bgcolor="F5F5F5">&nbsp;</td>
       <th valign="top" bordercolor="999999" bgcolor="F5F5F5">&nbsp;</th>
       <td width="11%" valign="top" bordercolor="999999" bgcolor="F5F5F5"><div align="center">#(Left(IPT_MatricInspetor,1) & '.' & Mid(IPT_MatricInspetor,2,3) & '.' & Mid(IPT_MatricInspetor,5,3) & '-' & Right(IPT_MatricInspetor,1))#</div></td>
       <td width="31%" valign="top" bordercolor="999999" bgcolor="F5F5F5">#Fun_Nome#</td>
       <td valign="top" bordercolor="999999" bgcolor="F5F5F5"> <div align="center">----------------------------</div></td>
     </tr>
    </cfloop>
  </cfoutput>     
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">&nbsp;</div></th>
    <th width="15%" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">&nbsp;</div></th>
    <th colspan="3" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">&nbsp;</div></th>
   </tr>  
   <tr>
    <th colspan="4" bordercolor="999999" bgcolor="F5F5F5"><div align="right">Data/Hora de Emiss&atilde;o:</div></th>
    <td  width="19%" bordercolor="999999" bgcolor="F5F5F5"><div align="right"><cfoutput>#DateFormat(Now(),"DD/MM/YYYY")#</cfoutput> - <cfoutput>#TimeFormat(Now(),'HH:MM')#</cfoutput></div></td>
  </tr>
  <tr>
    <th colspan="5" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><button type="button" onClick="imprimir()">Imprimir</button></th>
  </tr>


  <tr>
    <th colspan="5" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">&nbsp;</div></th>
  </tr>  

</table> 
 <cfcatch>
    <cfdump var="#cfcatch#">
</cfcatch>
</form>
</body>
</html>
</cftry>   


