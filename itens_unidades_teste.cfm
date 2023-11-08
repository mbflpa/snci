<!--- <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="permissao_negada.htm">
  <cfabort>
</cfif> --->

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">

function enviar(a){
 if (a=='0'||a=='1'||a=='2'){
 //alert(a);
 document.forms[a].submit();
 } else {
   alert('Selecione o campo');
 }
}
</script>
</head>

<body>
<cfinclude template="cabecalho.cfm">
<p align="center">
  <!--- Área de conteúdo   --->
</p>


<form action="itens1.cfm" method="post" target="_blank" name="frmopc">
      <table width="44%" align="center">
      <tr>
        <td colspan="2"><p align="center" class="titulo1"><strong><br>
          PONTOS DE AUDITORIA Por &Oacute;rg&Atilde;o Subordinador </strong></p>
            <p class="exibir"></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td><span class="exibir"><strong>Pesquisar por:</strong></span></td>
        </tr>
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td><span class="exibir"><strong><strong>
          <input name="ckTipo" type="radio" value="0" onClick="formulario.value = this.value" >
        </strong>Itens Solucionados  
        <input name="formulario" type="hidden">
        </strong></span></td>
        </tr>
      
	  <div id="campos">		</div>
      

      <tr>
        <td><span class="exibir"><strong>
          <input name="ckTipo" type="radio" value="1" onClick="formulario.value = this.value">
            Itens Pendentes </strong></span></td>
        <tr>
          <td><span class="exibir"><strong><strong>
            <input name="ckTipo" type="radio" value="2" onClick="formulario.value = this.value">
          </strong>Itens por Unidade </strong></span></td>
        <tr>
        <td><div align="center">
          <button onClick="enviar(formulario.value)" class="botao">Confirmar</button>
        </div></td>
  </table>
</form>
<form name="form1"  method="post" action="itens2.cfm">
</form>
<form name="form2"  method="post" action="itens3.cfm">
</form>

</body>
</html>
