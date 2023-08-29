<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfquery name="Consulta" datasource="#dsn_inspecao#">
SELECT * FROM Pesquisa WHERE Pes_NumInspecao = '#FORM.nu_inspecao#'
</cfquery>
<html>
<head>
<script type="text/javascript">
function tipo(a){
  document.formx.stipo.value=a;
}
function troca(a,b,c){
  document.formx.sninsp.value=a;
  document.formx.sobs.value=b;
  document.formx.sacao.value=c;

if (document.formx.stipo.value == "nulo" && c == "inc") {
   alert("Favor selecionar o tipo de observação a ser informado!");
   return false;
    }
if (b == "" && c == "inc") {
   if (confirm ("Você não informou texto algum no campo observação. Deseja continuar mesmo assim?"))
   { document.formx.sobs.value=" ";}
else {
   return false;
   } 
}
	
if (c == "inc") { d = "Inclusão?"; } else { d = "Exclusão?"; }

if (confirm ("Deseja continuar processo de "+d))
   { document.formx.submit(); }
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
<link href="css.css" rel="stylesheet" type="text/css">

 
<style type="text/css">
<!--
.style2 {font-weight: bold; color: #005782; text-decoration: underline; text-transform: uppercase; font-style: normal;}
-->
</style></head>

<body onLoad="atribuir();foco()">
<p align="center">&nbsp;</p>
<p align="center" class="titulos"><span class="style2"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Pesquisa de satisfa&ccedil;&atilde;o por</font></strong></span><span class="titulo1"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"> n&uacute;mero d</font></strong></span><span class="style2"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">e</font></strong></span><span class="titulo1"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"> inspe&ccedil;&atilde;o</font></strong></span><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
          <br>
          <br>
          </font></strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif" class="titulosClaro">A pesquisa serve para avaliarmos o Grau de Import&acirc;ncia e Satisfa&ccedil;&atilde;o Atribu&iacute;da a &Uacute;ltima Inspe&ccedil;&atilde;o<br>
          Realizada
em sua Unidade.</font></p>

<span class="red_titulo"><span class="red_titulo"><span class="red_titulo">
<p align="center">
<cfif Consulta.recordcount is 0>
    <span class="red_titulo"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong> N&uacute;mero
    da Inspe&ccedil;&atilde;o n&atilde;o encontrado</strong></font></span><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font><span class="titulos"></span><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong></strong></font>
  <cfelse>
 
<p align="center" class="titulos"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong> &nbsp;Nome: </strong><cfoutput>#Consulta.Pes_nome#</cfoutput></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></p>
<p align="center" class="titulos"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Lota&ccedil;&atilde;o:</strong>
    <cfoutput>#Consulta.Pes_lotacao#</cfoutput></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></p>
<hr noshade class="linha">
<div align="center" class="style1">



  <table width="100%" border="1" cellspacing="0" bordercolor="#FFFFFF" bgcolor="#FFFFCC">
    <tr>
      
      <td width="66%"><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Atributos</strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font></div></td>
      <td width="34%"><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>D&ecirc; sua nota de 1 a 10</strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font></div>        <div align="center" class="titulos"></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" bordercolor="#FFFFFF" bgcolor="lightyellow">
    <tr>
      
      <td width="51%"><div align="left" class="titulos"><strong><font size="1">1.<font face="Verdana, Arial, Helvetica, sans-serif"> Comunica&ccedil;&atilde;o
      Pessoal com o Inspecionado - Compreens&atilde;o Rec&iacute;proca</font></font><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"></font></font><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"></font></font><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"></font></font><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"></font></font><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"></font></font><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"></font></font><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif"></font></font></strong></div></td>
      <td width="26%"><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.Pes_comoestamos1#</cfoutput></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font>
      </div></td>
    </tr>
    <tr>
      
      <td><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">2.
                Postura Durante os Trabalhos - &Eacute;tica, Educa&ccedil;&atilde;o
      e Cortesia</font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></strong></div></td>
      <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.Pes_comoestamos2#</cfoutput></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font>
      </div></td>
    </tr>
    <tr>
      
      <td><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">3.
                Condu&ccedil;&atilde;o
                da Inspe&ccedil;&atilde;o - Simultaneidade com o M&iacute;nimo
                de Interrup&ccedil;&atilde;o
      das Atividades</font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></strong></div></td>
      <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.Pes_comoestamos3#</cfoutput></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font>
      </div></td>
    </tr>
    <tr>
      
      <td><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">4.
                Recomenda&ccedil;&otilde;es
      - Valor e Pertin&ecirc;ncia </font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></strong></div></td>
      <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.Pes_comoestamos4#</cfoutput></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font>
      </div></td>
    </tr>
    <tr>
      
      <td><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">5.
                Reuni&atilde;o
      de Encerramento - Simplicidade, Objetividade e Clareza </font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></strong></div></td>
      <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.Pes_comoestamos5#</cfoutput></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font>
      </div></td>
    </tr>
    <tr>
      
      <td><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">6.
                Relat&oacute;rio
      - Clareza, Consist&ecirc;ncia e Objetividade da Reda&ccedil;&atilde;o </font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></strong></div></td>
      <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.Pes_comoestamos6#</cfoutput></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font>
      </div></td>
    </tr>
    <tr>
      
      <td><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">7.
                Import&acirc;ncia
      da Inspe&ccedil;&atilde;o para o Aprimoramento da Unidade </font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></strong></div></td>
      <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.Pes_comoestamos7#</cfoutput></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font>
      </div></td>
    </tr>
  </table>
  <hr noshade class="linha">
  <div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
        <strong>  </strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><font size="1">Entre
      os Atributos Relacionados acima o mais Importante para </font></strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.Pes_Nome#</cfoutput></font><strong> <font size="1">foi:</font></strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><font size="1"></font></strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><strong><font size="1"></font></strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><font size="1"></font></strong><font color="#6699FF" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><strong><font size="1"></font></strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><font size="1"></font></strong><font color="#6699FF" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><strong><font size="1"></font></strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><font size="1"></font></strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><strong><font size="1"></font></strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><font size="1"></font></strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><strong><font size="1"></font></strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><font size="1"></font></strong><font color="#6699FF" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><strong><font size="1"></font></strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong><font size="1"></font></strong><font color="#6699FF" size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><strong><font size="1"></font></strong></font> <font size="1" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.Pes_MaisImportante#</cfoutput></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font><br>
  </div>
  <hr noshade class="linha">
  <div align="center" class="titulos">
<p><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cr&iacute;ticas, Sugest&otilde;es</strong> e/ou Elogios </font>
<form action="" name="form" method="post">
    <table width="634">
      <tr bgcolor="f7f7f7">
        <td height="22" colspan="2" valign="top" class="exibir"><div align="center"><strong><font face="Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp;&nbsp;&nbsp;N&deg; da Inspe&ccedil;&atilde;o:&nbsp;&nbsp;&nbsp;</font></strong><font face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.Pes_NumInspecao#</cfoutput></font>&nbsp;</div></td>
      </tr>
      <tr valign="top" bgcolor="f7f7f7">
        <td height="22" colspan="2" class="exibir"><label><span class="style4"><strong><font face="Verdana, Arial, Helvetica, sans-serif"><br>
        </font></strong>
            <textarea name="sugestoes" cols="100" rows="3" readonly wrap="VIRTUAL" id="sugestoes" face="verdana"><cfoutput>#Consulta.Pes_sugestoes#</cfoutput></textarea>
      <br>
      <textarea name="frmarea" cols="100" rows="3" wrap="VIRTUAL" id="frmarea" face="verdana"><cfoutput>#Consulta.Pes_observacao#</cfoutput></textarea>
      <br>
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="titulos">Observa&ccedil;&atilde;o</span>:&nbsp;&nbsp;&nbsp;&nbsp;
          <input name="frmtipo" type="radio" onClick="tipo(this.value)" value="cri">
          <span class="titulos">Cr&iacute;ticas</span> </label>
            <strong>
            <label> &nbsp;
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input name="frmtipo" type="radio" onClick="tipo(this.value)" value="sug">
            </label>
            </strong>
            <label class="titulos">Sugest&otilde;es</label>
          &nbsp;<strong><strong>
            <label>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="frmtipo" value="elo" onClick="tipo(this.value)">
            </label>
            </strong></strong> <span class="titulos">Elogios</span>
          <label> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="frmtipo" value="out" onClick="tipo(this.value)">
</label>
          </strong></strong> <span class="titulos">Outros</span></td>
      </tr>
      <tr bgcolor="f7f7f7">
        <td width="329" height="22" valign="top" class="exibir">
          
            <div align="left">
              <button name="submitExc" type="button" class="exibir" onClick="troca(frmninsp.value,frmarea.value,'exc');">Excluir</button>
              <input name="frmninsp" type="hidden" id="frmninsp" value="<cfoutput>#FORM.nu_inspecao#</cfoutput>">
            </div></td>
        <td width="293" height="22" valign="top" class="exibir"><div align="right">
          <button name="alterar" type="button" class="exibir" onClick="troca(frmninsp.value,frmarea.value,'inc');">Confirmar</button>
        </div></td>
      </tr>
</table>
      </p><!---  <p align="left" class="titulos"><strong><font face="Verdana, Arial, Helvetica, sans-serif"><br>
  N&deg; da Inspe&ccedil;&atilde;o:&nbsp;&nbsp;&nbsp;</font></strong><font face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#Consulta.numero#</cfoutput></font></strong></p> --->
<!--- <form action="excluir_formulario_ginsp.cfm" name="form" method="post"> ---><br>
  </form>
  <script type="text/javascript">
function atribuir()
{
<cfif consulta.Pes_tipo neq "">
 <cfif consulta.Pes_tipo eq 'cri'>document.form.frmtipo.item(0).checked=true; tipo('cri');</cfif>
 <cfif consulta.Pes_tipo eq 'sug'>document.form.frmtipo.item(1).checked=true; tipo('sug');</cfif>
 <cfif consulta.Pes_tipo eq 'elo'>document.form.frmtipo.item(2).checked=true; tipo('elo');</cfif> 
 <cfif consulta.Pes_tipo eq 'out'>document.form.frmtipo.item(3).checked=true; tipo('out');</cfif>  
</cfif>
}
</script>
  
<br>
  </p>
  </div>
</cfif>
<form name="formx" method="post" action="excluir_formulario_ginsp.cfm">
  <input name="sninsp" type="hidden" id="sninsp">
  <input name="sobs" type="hidden" id="sobs">
  <input name="stipo" type="hidden" id="stipo" value="nulo">
  <input name="dtinic" type="hidden" id="dtinic" value="<cfoutput>#form.dtinic#</cfoutput>">
  <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#form.dtfinal#</cfoutput>">
  <input name="sacao" type="hidden" id="sacao">
</form>
</body>
</html>
<%
RsConsulta.Close()
Set RsConsulta = Nothing
%>

