<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT RIP_NumInspecao, RIP_Unidade, Und_Descricao, RIP_Recomendacao_Inspetor, RIP_NumGrupo, RIP_NumItem, RIP_Comentario, RIP_Recomendacoes, INP_DtInicInspecao, INP_Responsavel, RIP_Melhoria
FROM (Unidades 
INNER JOIN ((Resultado_Inspecao 
INNER JOIN Inspecao ON (Resultado_Inspecao.RIP_Unidade = Inspecao.INP_Unidade) AND (Resultado_Inspecao.RIP_NumInspecao = Inspecao.INP_NumInspecao)) 
INNER JOIN Grupos_Verificacao ON Resultado_Inspecao.RIP_NumGrupo = Grupos_Verificacao.Grp_Codigo and right([Resultado_Inspecao.RIP_NumInspecao], 4) = Grp_Ano) ON Unidades.Und_Codigo = Inspecao.INP_Unidade) 
INNER JOIN Itens_Verificacao ON Grupos_Verificacao.Grp_Codigo = Itens_Verificacao.Itn_NumGrupo and right([Resultado_Inspecao.RIP_NumInspecao], 4) = Itn_Ano
WHERE RIP_NumInspecao='#URL.numero#' AND RIP_Unidade='#URL.unidade#' AND RIP_NumGrupo= #URL.numgrupo# AND RIP_NumItem=#URL.numitem#
</cfquery> 

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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
<script>
function popupPage() {
<cfoutput>  //página chamada, seguida dos parâmetros número, unidade, grupo e item
var page = "itens_controle_melhoria.cfm?numero=#URL.numero#&unidade=#URL.unidade#&numgrupo=#URL.numgrupo#&numitem=#URL.numitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=950,height=600,top=200,left=400,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}
</script>


<cfinclude template="cabecalho.cfm">
<table width="95%" height="100%">

<tr>
	  <td valign="top">
<!--- Área de conteúdo   --->
<table width="90%" height="100%" border="0" align="center">

	<tr>
	  <td colspan="5" bgcolor="f7f7f7"></td>
	  </tr>
	<tr>
	  <td colspan="5" bgcolor="f7f7f7"><div align="center"><span class="titulo1">SITUAÇÃO ENCONTRADA</span></div></td>
	  </tr>
	<tr>
	  <td colspan="5" bgcolor="f7f7f7">&nbsp;</td>
	  </tr>
	<tr>
	  <td width="10%" bgcolor="eeeeee"><span class="titulos">Auditoria</span></td>
	  <cfset Num_Insp = Left(rsItem.RIP_NumInspecao,2) & '.' & Mid(rsItem.RIP_NumInspecao,3,4) & '/' & Right(rsItem.RIP_NumInspecao,4)>
	  <td width="14%" bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#Num_Insp#</span></cfoutput></td>
	  <td width="9%" bgcolor="eeeeee"><span class="titulos">In&iacute;cio da Auditoria:</span></td>
	  <td colspan="2" bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#DateFormat(rsItem.INP_DtInicInspecao,"dd/mm/yyyy")#</span></cfoutput></td>  
	</tr>
	<tr>
	  <td bgcolor="eeeeee"><span class="titulos">Unidade:</span></td>
	  <td colspan="5" bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#rsItem.Und_Descricao#</span></cfoutput>	    <!---<span class="titulos">Respons&aacute;vel: </span>--->	    <!---<cfoutput><span class="titulosClaro">#rsItem.INP_Responsavel#</span></cfoutput>---></td>
	  </tr>
	<tr>
	  <td colspan="5" bgcolor="f7f7f7">&nbsp;</td>
	</tr>	
	 <tr>	 
	 <td bgcolor="f7f7f7" class="exibir"><span class="titulos">SITUAÇÃO ENCONTRADA:</span></td>
	 <td colspan="4" bgcolor="#f7f7f7" class="exibir"><textarea name="comentario" cols="120" rows="16" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Comentario#</cfoutput></textarea></td>
	 </tr>
	 <tr>
	   <td colspan="5" bgcolor="eeeeee">&nbsp;</td>
	   </tr>
	 <tr>
	  <td bgcolor="f7f7f7" class="exibir"><span class="titulos">Recomenda&ccedil;&otilde;es:
	    
	  </span></td> 
	  <td colspan="4" bgcolor="f7f7f7" class="exibir"><span class="titulos">
	    <textarea name="H_recom" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea>
	  </span></td>
	  </tr>
	 <tr>
	  <td colspan="5" bgcolor="f7f7f7" class="exibir">
	  <!---<cfif Trim(rsItem.RIP_Recomendacoes) is ''>
	    <div align="justify">
	      <cfelse> 
	      <cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput>
	        </div>
	  </cfif>--->
	  </td> 
	 </tr>
 <form name="form1" method="post" action="itens_controle_melhoria.cfm"> 
	 <tr>
	   <td colspan="5" bgcolor="eeeeee">&nbsp;</td>
	   </tr>
	 <tr>
	   <td colspan="5" bgcolor="eeeeee"><div align="center"><span class="titulo1">an&Aacute;lise do apontamento</span></div></td>
	   </tr>
	 <tr>
	   <td colspan="5" bgcolor="eeeeee">&nbsp;</td>
	   </tr>
	 <tr>
	   <td bgcolor="eeeeee">&nbsp;</td>
	   
	   <input name="numero" type="hidden" value="<cfoutput>#rsItem.RIP_NumInspecao#</cfoutput>">
	   <input name="unidade" type="hidden" value="<cfoutput>#rsItem.RIP_Unidade#</cfoutput>">
	   <input name="numgrupo" type="hidden" value="<cfoutput>#rsItem.RIP_NumGrupo#</cfoutput>">
	   <input name="numitem" type="hidden" value="<cfoutput>#rsItem.RIP_NumItem#</cfoutput>">
	   <td colspan="4" bgcolor="eeeeee"><div align="center"><strong><a href="orientacoes.htm"><span class="red_titulo">Orienta&ccedil;&otilde;es</span></a></strong></div></td>
	   </tr>	 
	 <tr>
	   <td bgcolor="#eeeeee">&nbsp;</td>
	   <td colspan="2" bgcolor="eeeeee"><span class="titulos">Apontamento no Objetivo/Item est&aacute; Incorreto</span></td>
	   <td colspan="2" bgcolor="#eeeeee"><input type="checkbox" name="incorreto" value="1"></td>
	 </tr>
	 <tr>
	   <td bgcolor="#eeeeee">&nbsp;</td>
	   <td colspan="2" bgcolor="eeeeee"><span class="titulos">Qualidade da Comunica&ccedil;&atilde;o</span></td>
	   <td colspan="2" bgcolor="#eeeeee"><input type="checkbox" name="comunicacao" value="1"></td>
	   </tr>
	 <tr>
	   <td bgcolor="#eeeeee">&nbsp;</td>
	   <td colspan="2" bgcolor="eeeeee"><span class="titulos">Apontamento Inadequado </span></td>
	   <td colspan="2" bgcolor="#eeeeee"><input type="checkbox" name="inadequado" value="1"></td>
	   </tr>
	 <tr>
	   <td bgcolor="#eeeeee">&nbsp;</td>
	   <td colspan="2" bgcolor="eeeeee"><span class="titulos">Falta de Objetividade </span></td>
	   <td colspan="2" bgcolor="#eeeeee"><input type="checkbox" name="objetividade" value="1"></td>
	   </tr>
	 <tr>
	   <td bgcolor="eeeeee">&nbsp;</td>
	   <td colspan="2" bgcolor="eeeeee"><span class="titulos">Refer&ecirc;ncia Normativa Incorreta </span></td>
	   <td colspan="2" bgcolor="eeeeee"><input type="checkbox" name="normativa" value="1"></td>
	   </tr>
	 <tr>
	   <td bgcolor="eeeeee">&nbsp;</td>
	   <td colspan="2" bgcolor="#eeeeee"><span class="titulos">Recomenda&ccedil;&atilde;o</span></td>
	   <td colspan="2" bgcolor="eeeeee"><input type="checkbox" name="recomendacao" value="1"></td>
	   </tr>
	 <tr>
	  <td colspan="5" bgcolor="#eeeeee">&nbsp;</td>
	</tr>    
	<tr>
	  <td colspan="2" bgcolor="eeeeee"><span class="titulos">Boa Pr&aacute;tica</span></td>
	  <td colspan="3" bgcolor="eeeeee"><input name="pratica" type="checkbox" value="1"></td>
	  </tr>
	<tr>
	  <td colspan="2" bgcolor="eeeeee"><span class="titulos">Oportunidade de Melhoria</span></td>
	  <td colspan="3" bgcolor="eeeeee"><input name="melhoria" type="checkbox" value="1">	    <!---<cfif rsItem.RIP_Melhoria eq 1>
	      Item j&aacute; selecionado
	      </cfif>---> </td>
	  </tr>
	<tr>
	  <td colspan="2" bgcolor="eeeeee">&nbsp;</td>
	  <td colspan="3" bgcolor="eeeeee">&nbsp;</td>
	 </tr>
	<tr>
	  <td bgcolor="#eeeeee">&nbsp;</td>
	  <td colspan="4" bgcolor="eeeeee"></td>
	  </tr>
	   <input type="hidden" name="corrigir" value="<cfoutput>#rsItem.RIP_Recomendacao_Inspetor#</cfoutput>">
    <tr>
      <td height="173" bgcolor="eeeeee"><span class="titulos">Hist&oacute;rico das Corre&ccedil;&otilde;es </span></td>
      <td colspan="4" rowspan="2" bgcolor="eeeeee"><cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(rsItem.RIP_Recomendacao_Inspetor) neq ''>
        <textarea name="H_correcao" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacao_Inspetor#</cfoutput></textarea>
      </cfif>
	  <textarea name="correcao" cols="120" rows="6" nome="correção" vazio="false" wrap="VIRTUAL" class="form" id="correcao"></textarea></td>
    </tr>	  
	<!---<tr>  
	   
	   <td bgcolor="#eeeeee"><span class="titulos">An&aacute;lise da SITUAÇÃO ENCONTRADA </span></td>	   
	     <td colspan="4" bgcolor="#eeeeee"><textarea name="recomendacao_inspetor" cols="120" rows="5" nome="recomendacao_inspetor" vazio="false" wrap="VIRTUAL" class="form" id="recomendacao_inspetor"></textarea></td>
	</tr>--->		     
	<tr>
	  <td colspan="5" align="center" bgcolor="eeeeee">&nbsp;</td>
	  </tr>
	<tr>
	  <td colspan="5" align="center" bgcolor="f7f7f7"><input type="button" class="botao" value="Fechar" onClick="window.close()">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input name="Submit" type="submit" class="botao" value="Confirmar"><span class="titulos">
	    </span></td>
	</tr>
 </form>
</table>
<!--- Fim Área de conteúdo --->
	  </td>
  </tr>
</table>
</body>
</html>