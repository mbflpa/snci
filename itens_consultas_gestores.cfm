<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>


<html>
<head>
<title>Sistema de Acompanhamento - Follow-up</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
function enviar(a){
 if (a=='0'||a=='1'||a=='2' || a=='3'){
 //alert(a);
 document.forms[a].submit();
 } else {
   alert('Selecione o Item');
 }
}
</script>
</head>

<body>

<p align="center">
  <!--- Área de conteúdo   --->
</p>

<br><br><br><br>
<form action="itens_consulta_data_gestores_pendentes.cfm" method="post" target="_blank" name="frmopc">
       <br><br>
      <table width="44%" align="center">
      <tr>
        <td><p align="center" class="titulo1"><strong><br>
          Acompanhamento dos Pontos de Auditoria </strong></p>
            <p class="exibir"></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td><span class="exibir"><strong>
          <input name="ckTipo" type="radio" value="0" onClick="formulario.value = this.value">
         Pontos Pendentes
        <input name="formulario" type="hidden">
        </strong></span></td>
      </tr>
	   <div id="campos"></div>
     <tr>
        <td><span class="exibir"><strong>
          <input name="ckTipo" type="radio" value="1" onClick="formulario.value = this.value">
         Pontos Solucionados </strong></span></td>
	  </tr>
		<tr>
          <td><span class="exibir"><strong>
            <input name="ckTipo" type="radio" value="2" onClick="formulario.value = this.value">
         Pontos Suspensos</strong></span></td>
        </tr>
		<!--- <tr>
          <td><span class="exibir"><strong>
            <input name="ckTipo" type="radio" value="3" onClick="formulario.value = this.value">
         Pontos Baixados</strong></span></td>
        </tr> --->
        <tr>
          <td colspan="2">&nbsp;</td>
        <tr>
		<tr>
          <td colspan="2">&nbsp;</td>
        <tr>
          <td colspan="2"><div align="center">
          <button onClick="enviar(formulario.value)" class="botao">Confirmar</button>
          </div></td>
		</tr>
  </table>
</form>
<form name="form1"  method="post" action="itens_consulta_data_gestores_solucionado.cfm">
</form>
<form name="form2"  method="post" action="itens_consulta_data_gestores_suspenso.cfm">
</form>
<!--- <form name="form3"  method="post" action="itens_consulta_data_presidencia_corporativo.cfm">
</form> --->
</body>
</html>

<!---<cfelse>
   <cfinclude template="permissao_negada.htm">
</cfif>--->