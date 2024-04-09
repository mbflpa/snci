<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>     
<!---
 <cfoutput>#Form.tpunid#</cfoutput> --->
 <html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
function validaForm() {
//alert('submit ok');
//alert('valor : ' + document.form1.tpunid.value);
//alert(document.form1.acao.value);
if (document.form1.acao.value != 'Filtro')
   {
    if (document.form1.frmcodunid.value == 'N') {return false;}
    document.form1.action="alterar_dados_unidade.cfm";
    document.form1.submit();
	}
else
   {
   document.form1.action="alterar_unidade.cfm";
   document.form1.submit();
   }				   
}
//---------------------------------
function voltar(){
       document.formvolta.submit();
    }
</script>
</head>
<body>
<cfquery name="rsSiglaSE" datasource="#dsn_inspecao#">
  SELECT Dir_Sigla FROM Diretoria WHERE Dir_Codigo = '#form.se#'
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsTipoUnid">
  SELECT Und_TipoUnidade, TUN_Descricao 
  FROM Tipo_Unidades INNER JOIN Unidades ON TUN_Codigo = Und_TipoUnidade 
  GROUP BY Und_TipoUnidade, TUN_Descricao, Und_CodDiretoria 
  HAVING (((Und_CodDiretoria)='#form.se#')) 
</cfquery>

<cfinclude template="cabecalho.cfm">
<form name="form1" method="post" onSubmit="return validaForm()">
<div align="center">
<!--- 	<cfif isDefined("Form.tpunid") and Form.tpunid neq "">
	 <tr>
      <td colspan="8" class="titulo1"><cfinclude template="cabecalho.cfm"></td>
    </tr>
	</cfif> --->
  <table width="95%" height="45" border="0" class="exibir">

    <tr>
      <td colspan="9">&nbsp;</td>
    </tr>

    <tr>
      <td colspan="9" class="titulo1"><div align="center">Tipos de unidades </div></td>
    </tr>
    <tr>
      <td colspan="9"><table width="1225" border="0">
        <tr>
          <td width="1065"><span class="titulo1">SE: <cfoutput>#form.se# - #rsSiglaSE.Dir_Sigla#</cfoutput></span><cfoutput></cfoutput></td>
          <td width="67"><div align="center">
            <button type="button" class="botao" onClick="voltar();">
            Voltar</button>
          </div></td>
          <td width="79"><div align="center">
            <input type="button" class="botao" onClick="window.close()" value="Fechar">
          </div></td>
        </tr>
      </table></td>
      <tr>
        <td colspan="9" class="titulos"><hr></td>
	     </tr>
    <tr>
      <td colspan="9">
	   <table width="95%" border="0" class="exibir">
	 
	   
	   <tr>
	   <td colspan="8" class="titulos">Filtrar por:</td>
	   </tr>
	   <cfset qtdcol = 0>
	   <tr>	  
    <cfoutput query="rsTipoUnid">
      <cfset ntam = len(trim(#TUN_Descricao#))>
      <cfset ntam = 14 - ntam>
        <cfset strnome = RepeatString(" ", ntam / 2) & left(trim(TUN_Descricao),14) & RepeatString(" ", ntam / 2)>
      <cfif qtdcol gte 10>
        <tr>		  </tr> 
        <cfset qtdcol = 0>
      </cfif>
      <td><div align="center">
        <div align="left">
          <input name="#Und_TipoUnidade#" type="button" class="exibir" onClick="document.form1.acao.value='Filtro'; document.form1.tpunid.value=this.name; validaForm()" value="#strnome#">
          </div>
        </div>	  </td>
      <cfset qtdcol = qtdcol + 1>
	  </cfoutput>
	  </tr>
	  </table>	  </td>
    </tr>

	<cfif isDefined("Form.tpunid") and Form.tpunid neq "">
	  <cfquery datasource="#dsn_inspecao#" name="qUnidade">
       SELECT Und_Codigo, Und_Sigla, Und_Descricao, Und_Status, Und_Email, Rep_Nome 
	   FROM Unidades INNER JOIN Reops ON Und_CodReop = Rep_Codigo 
	   where Und_CodDiretoria = #form.se# and Und_TipoUnidade = #Form.tpunid# ORDER BY Und_Descricao ASC
      </cfquery>
        <tr>
          <td colspan="9"><hr></td>
        </tr>
		<cfoutput>
      <tr>
      <td class="titulosClaro2"><div align="left">unidade:&nbsp;&nbsp;</div></td>
      <td colspan="8">
        <select name="frmcodunid" class="form" id="frmcodunid">
          <option selected="selected" value="N">---</option>
          <cfloop query="qUnidade">
            <option value="#Und_Codigo#">#trim(Und_Descricao)#</option>
          </cfloop>
        </select>
			  &nbsp;
			  <input name="alterar" type="button" class="exibir" onClick="if(document.form1.frmcodunid.value!='N'){document.form1.acao.value='Alterar'};document.form1.codigo.value=document.form1.frmcodunid.value; validaForm()" value="Alterar">      		</td>
    </tr>
</cfoutput>	
        <tr>
          <td colspan="9"><hr></td>
        </tr>
      <tr bgcolor="#D8E9F3">
      <td bgcolor="#CECED1"><div align="left"><span class="titulos">C&oacute;digo</span></div></td>
      <td width="67" bgcolor="#CECED1"><div align="left"><span class="titulos">Sigla</span></div></td>
      <td width="309" bgcolor="#CECED1"><div align="left"><span class="titulos">Descri&ccedil;&atilde;o</span></div></td>
      <td width="259" bgcolor="#CECED1"><div align="left"><span class="titulos">Email &Aacute;rea</span></div></td>
      <td width="259" bgcolor="#CECED1" class="titulos">Reate/Ger&ecirc;ncia</td>
      <td width="82" bgcolor="#CECED1"><span class="titulos">Sit.</span></td>
      </tr> 
<!--- 	<tr>
      <td colspan="8">&nbsp;</td>
      </tr> --->
<cfset scor = "FFFFFF">
  <cfoutput query="qUnidade">	  
        <tr bgcolor="##FFFFFF">
        <td bgcolor="#scor#">#Und_Codigo#</td>
        <td bgcolor="#scor#">#Und_Sigla#</td>
        <td bgcolor="#scor#">#Und_Descricao#</td>
        <td bgcolor="#scor#">#Und_Email#</td>
        <td bgcolor="#scor#">#Rep_Nome#</td>
        <td bgcolor="#scor#">#Und_Status#</td>
	  </tr> 
<!--- 	  <tr>
        <td colspan="8">&nbsp;</td>
        </tr> --->
  <cfif scor eq "FFFFFF">
  	<cfset scor = "CECED1">
  <cfelse>
   	<cfset scor = "FFFFFF">
  </cfif>
    </cfoutput>
    <tr>
      <td colspan="9">&nbsp;</td>
      <td width="10">&nbsp;</td>
    </tr> 
    <tr>
      <td colspan="9"><div align="center"><label><strong>Situa&ccedil;&atilde;o: &nbsp;&nbsp;&nbsp; A - Ativado &nbsp;&nbsp; D - Desativado</strong></label></div></td>
	</tr>
	<tr>
	   <td colspan="9">&nbsp;</td>
    </tr>
	<tr>
      <td><div align="center">
        </div></td>
      <td>&nbsp;</td>
      <td><div align="center">
        <button type="button" class="botao" onClick="voltar();">
          Voltar</button>
      </div></td>
      <td colspan="6"><div align="center">
        <input type="button" class="botao" onClick="window.close()" value="Fechar">
      </div></td>
      </tr>
<td width="212"></tr>

	<cfelse>
	  <tr>
	    <td colspan="9">&nbsp;</td>
      </tr>

	  <tr bgcolor="#FFB546">
      <td colspan="9"><div align="center" class="texto_help">
          <label><strong>Selecione o tipo de unidade a ser alterada.</strong></label>
      </div></td>
     </tr>
	</cfif>
 </table>
 

</div>
     <input name="tpunid" id="tpunid" type="hidden" value="">
	 <input name="codigo" id="codigo" type="hidden"value="">
	 <input name="acao" id="acao" type="hidden"value="">
	 <input name="se" type="hidden" value="<cfoutput>#form.se#</cfoutput>">
   <input name="evento" type="hidden" value="<cfoutput>#form.evento#</cfoutput>">
</form>
<form name="formvolta" method="post" action="index.cfm?opcao=permissao0">
  <input name="sacao" type="hidden" id="sacao" value="voltar">
  <input name="se" type="hidden" value="<cfoutput>#form.se#</cfoutput>">
</form>

</body>
</html>
