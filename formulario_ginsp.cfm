<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfif isdefined("form.insp")>
	<cfset vInsp = form.insp>
</cfif>

<cfif isdefined("vInsp")>
<cfquery name="verif" datasource="#dsn_inspecao#">
SELECT Pes_NumInspecao, Pes_DtPesquisa FROM Pesquisa WHERE Pes_NumInspecao = '#FORM.insp#'
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="qEmpr">
SELECT Und_Descricao, INP_Responsavel, INP_DtInicInspecao FROM Inspecao INNER JOIN Unidades ON Inspecao.INP_Unidade = Unidades.Und_codigo
WHERE INP_NumInspecao = '#vInsp#'
</cfquery>

<cfset Data_Inspecao = DateFormat(qEmpr.INP_DtInicInspecao,"yyyy/mm/dd")>
<cfset Data_Hoje = DateFormat(now(),"yyyy/mm/dd")>

</cfif>

<html>
<head>

<script language="JavaScript">
	//permite digitaçao apenas de valores numéricos
	function sohNumeros() {
	var tecla = window.event.keyCode;
	//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
	if ((tecla != 8) && (tecla != 9) && (tecla != 27)) {
		if ((tecla < 48) || (tecla > 57)) {
		  if ((tecla > 96) || (tecla < 105)) {
			event.returnValue = false;
		  }
		}
	}
	}
function troca(a){

if (a == "env") { b = "Enviar de Formulário?"; } else { b = "Limpar Formulário?"; }

if (confirm ("Deseja continuar processo de "+b))
   { document.form1.submit(); }
else {
   return false;
   } 
}	
</script>


<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.linha {
	border: thin dotted #CCCCCC;
}
-->
</style>



<link href="CSS.css" rel="stylesheet" type="text/css">

<style type="text/css">
<!--
.style4 {text-decoration: none; color: #053C7E;}
-->
</style></head>

<body onLoad="frm_Funcionario.insp.focus()">
<p align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><img src="logo.gif" width="113" height="24"><br>
  <br>
  <span class="titulos"><font size="3"><cfoutput>#DR#</cfoutput></font></span><br>
  </font><font size="3" face="Verdana, Arial, Helvetica, sans-serif"><br>
  <font color="#FF0000" size="2"><br>
Sua Opini&atilde;o &eacute; Importante!</font></font></strong></p>
<p align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
  <br>
  </font></strong><span class="exibir"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">A </font></span><span class="style4"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">p</font></span><span class="exibir"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">esquisa serve para avaliarmos</font></span><span class="exibir"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> o Grau de Import&acirc;ncia e Satisfa&ccedil;&atilde;o 
  Atribu&iacute;da a &Uacute;ltima Inspe&ccedil;&atilde;o<br>
  Realizada em sua Unidade.</font></span></p><br>
<table width="100%" border="0" align="center">
  <tr>
    <td><div align="center"><span class="exibir">Crit&eacute;rio para avalia&ccedil;&atilde;o das notas:</span></div></td>
  </tr>
</table>
<br><br>
<table width="100%" border="1" align="center" bordercolor="#999999">
       <tr>
         <td width="20%" class="red_titulo"><div align="center"><strong>&Oacute;TIMO</strong></div></td>
         <td width="20%" class="red_titulo"><div align="center"><strong>BOM</strong></div></td>
         <td width="20%" class="red_titulo"><div align="center"><strong>REGULAR</strong></div></td>
         <td width="20%" class="red_titulo"><div align="center"><strong>RUIM</strong></div></td>
         <td width="20%" class="red_titulo"><div align="center"><strong>P&Eacute;SSIMO</strong></div></td>
       </tr>
       <tr>
         <td class="red_titulo"><div align="center"><strong>10-9</strong></div></td>
         <td class="red_titulo"><div align="center"><strong>8-7</strong></div></td>
         <td class="red_titulo"><div align="center"><strong>6-5</strong></div></td>
         <td class="red_titulo"><div align="center"><strong>4-3</strong></div></td>
         <td class="red_titulo"><div align="center"><strong>1-2</strong></div></td>
       </tr>
</table>
	 <br><br>
	 <cfform name="frm_Funcionario" action="" method="post">
	 <table align="center">
	 <tr>
		 <td><span class="exibir"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><font size="1">N&deg; da Inspe&ccedil;&atilde;o</font></font>:</strong></font></span></td>
         <td><cfinput type="text" name="insp" face="verdana" class="form" id="insp" style="border:none;background-color:lightyellow" maxlength="10" required="yes" message="Verifique novamente o número da inspeção!" validate="integer"></td>
		 <td class="exibir">Ex: <cfoutput>#Cod_DR#</cfoutput>09992005</td>
         <td><button name="submit" type="submit" onClick="aguarda(this)">Consultar</button></td>
		 <td></td>
      </tr>
	  </table>
</cfform>
	 
	<cfif isdefined("vInsp")>
	<cfif verif.recordcount neq 0>
		<div align="center"><span class="red_titulo">A Pesquisa de Satisfação da inspeção <cfoutput>#verif.Pes_NumInspecao#</cfoutput> já foi enviada em <cfoutput>#dateformat(verif.Pes_DtPesquisa,"DD/MM/YYYY")#</cfoutput>! </span></div>
		<cfelse>
	<cfif qEmpr.recordcount eq 0>
  		<div align="center"><span class="red_titulo"> Inspe&ccedil;&atilde;o não localizada. </span></div>
  		<cfelse>
<cfform name="form1" target="_self" action="formulario_ginsp_action.cfm">
<table align="center">
	<tr>
	<td class="titulos">Unidade:</td>
	<td><cfinput name="unidade" value="#qEmpr.Und_Descricao#" type="text" face="verdana" class="form" readonly="true" id="nome" style="border:none;background-color:lightyellow" size="45" maxlength="45"></td>
	</tr>
	<tr>
	<td class="titulos">Nome:</td>
	<td><cfinput name="nome" value="#qEmpr.INP_Responsavel#" type="text" face="verdana" class="form" readonly="true" id="nome" style="border:none;background-color:lightyellow" size="45" maxlength="45"></td>
	</tr>
</table>	
<hr noshade class="linha">
<div align="center">
  <table width="100%" border="1" cellspacing="0" bordercolor="#FFFFFF" bgcolor="#FFFFCC">
    <tr>
      <td colspan="2"><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>
	  <div align="center" class="exibir"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></div>
	  <div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Atributos</strong></font></div></td>
      <td width="16%" height="42"><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>D&ecirc; 
          sua nota de 1 a 10</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" bordercolor="#FFFFFF" bgcolor="lightyellow">
    <tr>
      <td width="9%">
         <div align="center">
         </div>
      </td>
      <td width="75%"><div align="left" class="exibir"><strong><font size="1">1.<font face="Verdana, Arial, Helvetica, sans-serif"> 
          Comunica&ccedil;&atilde;o Pessoal com o Inspecionado - Compreens&atilde;o 
          Rec&iacute;proca</font></font></strong></div></td>
      <td width="16%"><div align="center">
          <select name="select1" class="form">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
            <option value="6">6</option>
            <option value="7">7</option>
            <option value="8">8</option>
            <option value="9">9</option>
            <option value="10">10</option>
        </select>
      </div></td>
    </tr>
    <tr>
      <td height="28"><div align="center">
      </div></td>
      <td><div align="left" class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">2. 
          Postura Durante os Trabalhos - &Eacute;tica, Educa&ccedil;&atilde;o 
          e Cortesia</font></strong></div></td>
      <td><div align="center">
        <select name="select2" class="form">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
            <option value="6">6</option>
            <option value="7">7</option>
            <option value="8">8</option>
            <option value="9">9</option>
            <option value="10">10</option>
        </select>
      </div></td>
    </tr>
    <tr>
      <td height="23"><div align="center">
      </div></td>
      <td><div align="left" class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">3. 
          Condu&ccedil;&atilde;o da Inspe&ccedil;&atilde;o - Simultaneidade com 
          o M&iacute;nimo de Interrup&ccedil;&atilde;o das Atividades</font></strong></div></td>
      <td><div align="center">
        <select name="select3" class="form">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
            <option value="6">6</option>
            <option value="7">7</option>
            <option value="8">8</option>
            <option value="9">9</option>
            <option value="10">10</option>
        </select>
      </div></td>
    </tr>
    <tr>
      <td><div align="center">
      </div></td>
      <td><div align="left" class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">4. 
          Recomenda&ccedil;&otilde;es - Valor e Pertin&ecirc;ncia </font></strong></div></td>
      <td><div align="center">
        <select name="select4" class="form">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
            <option value="6">6</option>
            <option value="7">7</option>
            <option value="8">8</option>
            <option value="9">9</option>
            <option value="10">10</option>
        </select>
      </div></td>
    </tr>
    <tr>
      <td><div align="center">
      </div></td>
      <td><div align="left" class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">5. 
          Reuni&atilde;o de Encerramento - Simplicidade, Objetividade e Clareza 
          </font></strong></div></td>
      <td><div align="center">
        <select name="select5" class="form">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
            <option value="6">6</option>
            <option value="7">7</option>
            <option value="8">8</option>
            <option value="9">9</option>
            <option value="10">10</option>
        </select>
      </div></td>
    </tr>
    <tr>
      <td><div align="center">
      </div></td>
      <td><div align="left" class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">6. 
          Relat&oacute;rio - Clareza, Consist&ecirc;ncia e Objetividade da Reda&ccedil;&atilde;o 
          </font></strong></div></td>
      <td><div align="center">
        <select name="select6" class="form">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
            <option value="6">6</option>
            <option value="7">7</option>
            <option value="8">8</option>
            <option value="9">9</option>
            <option value="10">10</option>
        </select>
      </div></td>
    </tr>
    <tr>
      <td><div align="center">
      </div></td>
      <td><div align="left" class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">7. 
          Import&acirc;ncia da Inspe&ccedil;&atilde;o para o Aprimoramento da 
          Unidade </font></strong></div></td>
      <td><div align="center">
        <select name="select7" class="form">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
            <option value="6">6</option>
            <option value="7">7</option>
            <option value="8">8</option>
            <option value="9">9</option>
            <option value="10">10</option>
        </select> 
      </div></td>
    </tr>
  </table>
  <hr noshade class="linha">
  <div align="center"><span class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Entre 
    os Atributos Relacionados acima indique o mais Importante:</font></span> <br>
    <br>  
  </div>
  <table width="71%" border="1" align="center" cellspacing="0" bordercolor="#FFFFFF" bgcolor="lightyellow">
    <tr>
      <td><div align="left">          
       
          <input name="mais_importante" type="radio" value="Comunicação Pessoal com o Inspencionado - Compreensão Recíproca" checked>
          <span class="exibir"><strong><font size="1">1.<font face="Verdana, Arial, Helvetica, sans-serif"> 
          Comunicação Pessoal com o Inspecionado - Compreensão Recíproca</font></font></strong></span><strong><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"><br>
      </font></font></strong></div></td>
    </tr>
    <tr>
      <td><div align="left">        
      
          <input type="radio" name="mais_importante" value="Postura Durante os Trabalhos - Ética, Educação e Cortesia">
          <span class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">2. 
          Postura Durante os Trabalhos - Ética, Educação e Cortesia</font><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"> 
          </font></font></strong></span></div></td>
    </tr>
    <tr>
      <td><div align="left">        
      
          <input type="radio" name="mais_importante" value="Condução da Inspeção - Simultaneidade com o Mínimo de Interrupção das Atividades">
          <span class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">3. 
          Condução da Inspeção - Simultaneidade como Mínimo de Interrupção das Atividades</font><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"> 
          </font></font></strong></span></div></td>
    </tr>
    <tr>
      <td><div align="left">        
        
          <input type="radio" name="mais_importante" value="Recomendações - Valor e Pertinência">
          <span class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">4. 
          Recomendações - Valor e Pertinência</font><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"></font></font></strong></span><strong><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"><br>
          </font></font></strong></div></td>
    </tr>
    <tr>
      <td><div align="left">        
       
          <input type="radio" name="mais_importante" value="Reunião de Encerramento - Simplicidade, Objetividade e Clareza">
          <span class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">5. 
          Reunião de Encerramento - Simplicidade, Objetividade e Clareza</font></strong></span></div></td>
    </tr>
    <tr>
      <td><div align="left">        
      
          <input type="radio" name="mais_importante" value="Relatório - Clareza, Consistência e Objetividade da Redação">
          <span class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">6. 
          Relatório - Clareza, Consistência e Objetividade da Redação 
          </font></strong></span></div></td>
    </tr>
    <tr>
      <td><div align="left">        
     
          <input type="radio" name="mais_importante" value="Importância da Inspeção para o Aprimoramento da Unidade">
          <span class="exibir"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">7. 
          Importância da Inspeção para o Aprimoramento da Unidade </font></strong></span></div></td>
    </tr>
  </table>
 
  <hr noshade class="linha">
  <div align="center"><span class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Cr&iacute;ticas,  Sugestões e/ou Elogios </font></span><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
    <br>
    </font>
      <textarea name="sugestoes" cols="50" rows="5" wrap="VIRTUAL" class="form" id="sugestoes" face="verdana"></textarea>
   
</div>
  <p align="center"><br>
   <table align="center">
    <tr>
	<input type="hidden" name="inspecao" value="<cfoutput>#vInsp#</cfoutput>">
	<cfif Data_Hoje gt Data_Inspecao>
	 <td><button name="alterar" type="button" class="exibir" onClick="troca('env');">Enviar Formul&aacute;rio</button>
	  <!---  <input name="Submit" type="submit" class="botao" value="Enviar Formul&aacute;rio"></td> --->
    <cfelse>
	 <!---  <td><input name="Submit" type="submit" class="botao" value="Enviar Formul&aacute;rio" disabled></td> --->
  	</cfif>
	<td>&nbsp;</td>
	<td><input name="Submit2" type="reset" class="botao" value="Limpar Formul&aacute;rio"></td>
	<td>&nbsp;</td>
    </tr>
  </table>
</p>
</cfform>
</cfif>
</cfif>
</cfif>

</body>
</html>