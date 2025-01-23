
<cfinclude template="../../../parametros.cfm">
	<cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller" 
	method="geraMatriculaInspetor" returnvariable="qryInspetor">
	
	</cfinvoke>

    <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller" 
	method="geraRelatorio" returnvariable="qryRelatorio"></cfinvoke>
	
	<cfset qtItens = qryRelatorio.recordcount>
		
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css.css" rel="stylesheet" type="text/css" />
<script>
// Função imprimir
function imprimir(){
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
<table border="0" width="100%">
 <cfif qryRelatorio.recordcount is 0>
   <tr>    
    <td  valign="baseline" bordercolor="999999" bgcolor="F5F5F5" class="red_titulo"><div align="center"><span class="style2">Caro colaborador não há registros para à área solicitada</span></div></td>    
   </tr>
</table>
   <cfabort>
 </cfif>
  
<tr>
  <th width="23%" rowspan="2"><div align="left"></div></th>
</tr>
<table width="100%" border="0" cellspacing="4">
  <tr>
      <th colspan="4" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"></th>
  </tr> 
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="2" rowspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><img src="../../geral/img/logoCorreios.gif" alt="Logo ECT" width="167" align="left" /></th>
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left"><span class="style2">Ger&ecirc;ncia de Macrorregi&atilde;o de Auditoria</span></div></th>
    </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left"><span class="style2">Relat&oacute;rio Preliminar de Auditoria </span></div></th>
    </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="4" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"></th>
    </tr> 
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Diretoria</div></th>
    <td colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left"><cfoutput>#DR#</cfoutput></div></td>
    </tr>
  <tr>
    <th width="1%" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left" class="labelcell"></div></th>
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Unidade:</div></th>
    <td colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="justify"><cfoutput>#qryRelatorio.Und_Descricao#</cfoutput></div></td>
    </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left" class="labelcell"></div></th>
    <th colspan="2" valign="top" bordercolor="#999999" bgcolor="F5F5F5" scope="row"><div align="left">Per&iacute;odo da Auditoria:</div></th>
    <td colspan="2" valign="top" bordercolor="#999999" bgcolor="F5F5F5" scope="row"><div align="justify"><cfoutput>#DateFormat(qryRelatorio.INP_DtInicInspecao,'dd/mm/yyyy')#</cfoutput>
    
      <label class="fieldcell"> 
          a      </label>
      <cfoutput>#DateFormat(qryRelatorio.INP_DtFimInspecao,'dd/mm/yyyy')#</cfoutput></div></td>
    </tr>
    <cfset Num_Insp = Left(qryRelatorio.INP_NumInspecao,2) & '.' & Mid(qryRelatorio.INP_NumInspecao,3,4) & '/' & Right(qryRelatorio.INP_NumInspecao,4)>  
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left" class="labelcell"></div></th>
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left"> N&ordm; da Auditoria:</div></th>
    <td colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="justify"><cfoutput>#Num_Insp#</cfoutput></div></td>
    </tr>
  <tr>
    <th colspan="5" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
  </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="4" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">4. Situação Encontrada, Causas Prov&aacute;veis, Manisfesta&ccedil;&otilde;es e Recomenda&ccedil;&otilde;es </div></th>
    </tr>
  <tr>
    <th colspan="5" valign="top" bordercolor="999999" bgcolor="CCCCCC" scope="row"><div align="justify">&nbsp;</div></th>
    </tr>
 
  <cfset numGrav = 0>
  <cfset muitoGrav = 0>
  <cfset CP = 0> 
 	 
 
<cfoutput query="qryRelatorio" group="Grp_Codigo">
 
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Objetivo: #Grp_Codigo#</div></th>
    <td colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">#Grp_Descricao#</div></td>
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
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Item: #Itn_NumItem#</div></th>
    <td colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">#Itn_Descricao#</div></td>
    </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left" class="labelcell"><div align="center"></div></div> </th>
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Risco: </div></th>
    <td colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="justify">#SGrav#</div></td>
    </tr>
  <tr>
    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><cfset coment = Replace(RIP_Comentario,"
","<BR>" ,"All")></td>
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Situa&ccedil;&atilde;o Encontrada:</div></th>
    <td colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="justify">#coment#</div></td>
    </tr>
  <tr>
    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</td>
    <th colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Situa&ccedil;&atilde;o:</div></th>
    <td colspan="2" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="justify"><cfif qryRelatorio.Pos_Situacao_Resp eq 0>Responder
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
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"></th>	  
    <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller" 
	  method="geraAnexoNumero" returnvariable="qryAnexos">
		<cfinvokeargument name="vNumInspecao" value="#qryRelatorio.INP_NumInspecao#">
		<cfinvokeargument name="vNumGrupo" value="#qryRelatorio.Grp_Codigo#">
		<cfinvokeargument name="vNumItem" value="#qryRelatorio.Itn_NumItem#">
	</cfinvoke>         
		 <th colspan="2" bordercolor="999999" bgcolor="F5F5F5">
		 <div align="left" id="anexo">Anexo:</div></th>
	     <td colspan="2" bordercolor="999999" bgcolor="F5F5F5"><div align="left" id="arquivo">
	         <cfloop query="qryAnexos">	
             <a target="_blank" href="#qryAnexos.Ane_Caminho#">
		     <span class="link1">#ListLast(qryAnexos.Ane_Caminho,'\')#</span><br></a>
             </cfloop>
          </div></td>     		 
  </tr> 
</cfoutput> 
  <tr>
    <td colspan="5" bordercolor="999999" bgcolor="CCCCCC" scope="row">&nbsp;</td>
  </tr>   
</cfoutput> 
  <tr>
    <td bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</td>
    <th colspan="4" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Equipe:</div></th>
  </tr>
  <tr>
    <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
    <th colspan="3" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left"></div></th>
    <th width="27%" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left"></div>
      Assinaturas:</th>
    </tr>
	 <cfset mat = qryRelatorio.INP_Coordenador>
	 <cfset matricula = Left(mat,1) & '.' & Mid(mat,2,3) & '.' & Mid(mat,5,3) & '-' & Right(mat,1)>	
     <tr>
       <th valign="top" bordercolor="999999" bgcolor="F5F5F5">&nbsp;</th>
       <th width="11%" valign="top" bordercolor="999999" bgcolor="F5F5F5"><div align="left">Coordenador:</div></th>
       <td width="14%" valign="top" bordercolor="999999" bgcolor="F5F5F5"><div align="center"><cfoutput>
            <div align="center">#matricula#</div>
       </cfoutput></div></td>
       <td width="47%" valign="top" bordercolor="999999" bgcolor="F5F5F5"><div align="left"><cfoutput>#qryRelatorio.Fun_Nome#</cfoutput></div></td>
       <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">---------------------------------------</div></td>
     </tr>
     <tr>
       <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
       <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">Analista(s):</div></th>
       <th colspan="3" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</th>
     </tr>	  
   
  <cfoutput query= "qryInspetor"> 	   	  
     <tr>
       <td valign="top" bordercolor="999999" bgcolor="F5F5F5">&nbsp;</td>
       <th valign="top" bordercolor="999999" bgcolor="F5F5F5">&nbsp;</th>
       <td  width="14%" valign="top" bordercolor="999999" bgcolor="F5F5F5"><div align="center">#(Left(IPT_MatricInspetor,1) & '.' & Mid(IPT_MatricInspetor,2,3) & '.' & Mid(IPT_MatricInspetor,5,3) & '-' & Right(IPT_MatricInspetor,1))#</div></td>
       <td valign="top" bordercolor="999999" bgcolor="F5F5F5"><div align="left">#Fun_Nome#</div></td>
       <td valign="top" bordercolor="999999" bgcolor="F5F5F5"> <div align="center">---------------------------------------</div></td>
     </tr>
  </cfoutput> 	 
    <tr>
      <th colspan="5" bordercolor="999999" bgcolor="F5F5F5">&nbsp;</th>
    </tr>
    <tr>      
      <th width="1%" bordercolor="999999" bgcolor="F5F5F5">&nbsp;</th>
      <th colspan="3" bordercolor="999999" bgcolor="F5F5F5"><div align="right">Data/Hora de Emiss&atilde;o:</div></th>
      <td bordercolor="999999" bgcolor="F5F5F5"><cfoutput>#DateFormat(Now(),"DD/MM/YYYY")#</cfoutput> - <cfoutput>#TimeFormat(Now(),'HH:MM')#</cfoutput></td>
    </tr>
    <tr>
      <th colspan="5" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><button type="button" onClick="imprimir()">Imprimir</button></th>
    </tr>
    <tr>    
    <td colspan="5" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">&nbsp;</td>
    </tr>  
</table> 
</form>   
</body>
</html>
