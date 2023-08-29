<cfset evento = 'document.frm1.arquivo.focus()'>
<!--- <cfdirectory name="qList" filter="*.*" sort="name desc" directory="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\">
<cfloop query= "qList">
 <cffile action="delete" file="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\#name#">
</cfloop> --->
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
	a = a.toUpperCase();
if (a.indexOf(".CSV") == -1) 
    {
      alert("Formato difere do (CSV)");
      return false;
   } 
if (b.length != 23) {
   //alert("Preencher o Nº da Inspeção com 23 dígitos");
   //return false;
   }
}
//==========
function mostrar(x){
 var a = x.substring((x.length - 23), x.length);
// document.frm1.numero_inspecao.value = a;
}
</script>
</head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<!--- <cfinclude template="cabecalho.cfm"> --->
<body onLoad="<cfoutput>#evento#</cfoutput>" text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">

<div id="Layer1" style="position:absolute; left:11px; top:6px; width:7px; height:6px; z-index:1"></div>

<div align="center"></div>
<a name="Inicio" id="Inicio"></a>
<!--- <cfinclude template="cabecalho.cfm"> --->

<form name="frm1" action="Itens_ajustaremlote1.cfm?flush=true" enctype="multipart/form-data" method="post"  onSubmit="return troca(arquivo.value);">

<table width="85%" border="0" align="center"><br><br><br><br><br>
  
  <tr align="center"><br><br>
    <td colspan="3" class="titulo1">Transmiss&Atilde;o de ITENS_para atualiza&ccedil;&atilde;o em lote</td>
  </tr>
  <tr>
    <td width="14%">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td width="86%">&nbsp;</td>
  </tr>
  <tr>    
    <td class="titulos"><div align="right">Arquivo(CSV):</div></td>
    <td><input name="arquivo" type="file" class="botao" size="50" onChange="mostrar(this.value)"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input name="confirmar" type="submit" class="botao" value="Confirmar"></td>
  </tr>
</table>
</form>
</body>
</html>