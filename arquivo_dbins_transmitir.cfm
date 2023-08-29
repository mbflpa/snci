<cfset evento = 'document.frm1.arquivo.focus()'>
 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
function troca(a,b){
//alert(a + ' ' + b);
if (a == "" || b == "") {
   alert("Favor preencher os dois campos!");
   return false;
    }
if (a.indexOf(".xml") == -1) 
    {
      alert("Formato difere do (XML) ou está fora do padrão gerado pelo SGI");
      return false;
   } 
if (b.length != 23) {
   alert("Preencher o Nº da Inspeção com 23 dígitos");
   return false;
   }
}
//==========
function mostrar(x){
 var a = x.substring((x.length - 23), x.length);
 document.frm1.numero_inspecao.value = a;
}
</script>
</head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<body onLoad="<cfoutput>#evento#</cfoutput>" text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">

<div id="Layer1" style="position:absolute; left:11px; top:6px; width:7px; height:6px; z-index:1"></div>

<div align="center"></div>
<a name="Inicio" id="Inicio"></a>
<cfinclude template="cabecalho.cfm">

<form name="frm1" action="arquivo_dbins_visualizar.cfm?flush=true" enctype="multipart/form-data" method="post"  onSubmit="return troca(arquivo.value,numero_inspecao.value);">

<table width="100%" border="0" align="center"><br><br><br><br><br>
  
  <tr align="center"><br><br>
    <td colspan="4" class="titulo1">Transmiss&Atilde;o de Arquivo</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td width="65%">&nbsp;</td>
  </tr>
  <tr>    
    <td width="27%" class="titulos">&nbsp;</td>
    <td width="8%" class="titulos">Arquivo:</td>
    <td><input name="arquivo" type="file" class="botao" size="50" onChange="mostrar(this.value)"></td>
  </tr>
  <tr>
   <td class="titulos">&nbsp;</td>
   <td class="titulos">N&ordm; Relat&oacute;rio:</td>
   <td><input name="numero_inspecao" type="text" class="form" size="30" maxlength="23" readonly="Yes"></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td><input name="confirmar" type="submit" class="botao" value="Confirmar"></td>
  </tr>
</table>
</form>
</body>
</html>