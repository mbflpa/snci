<!--- <cfif not isDefined("Session.conteudo")>
	<cflocation url="index.cfm">
</cfif> 
<cfif Session.Acesso_Usu neq 'A'>
	<cflocation url="Atend_Abrir_Energetico.cfm">
</cfif> ---> 
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <title>Sistema Nacional de Controle Interno</title>
 <link href="../../estilo.css" rel="stylesheet" type="text/css">
 <link href="css.css" rel="stylesheet" type="text/css">
<!--- <cfinclude template="css/estilo.css"> --->
<script type="text/javascript">
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	if ((tecla < 48) || (tecla > 57)) {
	//  if () {
		event.returnValue = false;
	 // }
	}
}
}
//================
//Formatar data
function mascara_data(sdata)
{
	switch (sdata.value.length)
	{
		case 2:
			sdata.value += "/";
			break;
		case 5:
			sdata.value += "/";
			break;
	}
}
//=======================
function troca(a,b,c){

//alert(a+b+c+d+e);

if (a == "") {
   alert("Informar o campo data!");
   return false;
   }
if (b == "") {
   alert("Informar o campo descrição!");
   return false;
   }

if (a.length != 10){
   alert("Preencher campo data ex. dd/mm/aaaa");
   return false;
}
b = b.toUpperCase();

if (c == "inc") { 
    d = "Inclusão?"; 
 } 
 else if (c == "alt") { 
  d = "Alteração?"; 
  }
else
  { d = "Exclusão?"; }
   
if (confirm ("Deseja continuar processo de "+d))
   {
    document.formx.sfrmdata.value=a;
    document.formx.sfrmdesc.value=b;
    document.formx.sacao.value=c;
    document.formx.submit(); 
	}
else
   {
   return false;
   }
}
</script>
<style type="text/css">
<!--
.style1 {font-size: 10px}
.style3 {
	font-size: 14px;
	font-family: "Times New Roman", Times, serif;
}
-->
</style>
</head>
<body onLoad="foco()">

 <script type="text/javascript">
    document.write("<table width='" + largura() + "' height='" + altura() + "' border='0'>");
 </script>
<!---     <tr height="5%">
	  <td><div id="menu"><cfinclude template="menus/menu.cfm"></div><hr width="95%"></td>
	</tr> --->
<tr height="3%">
  <td align="center" valign="top" class="titulo"><div align="center" class="titulo1">Cadastro de Feriados Nacionais </div></td>
</tr><tr height="90%"><td valign="top" align="center">
<!--- Início da área de conteúdo --->

<form action="" method="POST" name="form1">
  <table width="417" align="center" class="exibir">
    <tr valign="baseline">
      <td colspan="2" align="center" class="destaque"><hr width="95%"></td>
      </tr>
    <tr valign="baseline">
      <td align="center" class="titulos"><div align="left">Data:</div></td>
      <td width="396" align="center" class="destaque"><div align="left">
        <input name="frmdata" type="text" class="form" id="frmdata" onKeyPress="numericos()" onKeyDown="mascara_data(this)" size="12" maxlength="10">
      </div></td>
      </tr>
    <tr valign="baseline">
      <td width="64" align="center" class="titulos"><div align="left">Descri&ccedil;&atilde;o:</div></td>
      <td align="center" class="destaque"><div align="left">
            <input name="frmdesc" type="text" class="form" id="frmdesc" size="52" maxlength="50" vazio="false" nome="Nome">
      </div>
        </td>
      </tr>
        <tr valign="baseline">
      <td colspan="2" class="destaque"><div align="right">
        <button name="submitAlt" type="button" class="botao" onClick="troca(frmdata.value,frmdesc.value,'inc');">Confirmar</button>
      </div></td>
    </tr>
    </table>
	</form>
<p>

<hr width="95%">
</p>
<cfquery name="qVis" datasource="#dsn_inspecao#">
 SELECT Fer_Data, Fer_Descricao FROM FeriadoNacional order by Fer_Data
</cfquery>
<table width="666" border="0" align="center">
  <tr class="destaque"  bgcolor="eeeeee">
    <td width="76" height="16" align="center" bgcolor="#D7D7D7" class="titulos"><div align="left">Data</div></td>
    <td width="274" align="center" bgcolor="#D7D7D7" class="titulos"><div align="left">Descri&ccedil;&atilde;o do Feriado Nacional </div>      <div align="left"></div></td>
    <td width="128" align="center" bgcolor="#D7D7D7" class="titulos">Dia da semana </td>
    <td colspan="4" align="center" bgcolor="#D7D7D7"><div align="center" class="titulos">Que fazer?      </div></td>
    </tr>
	<cfset scor = 'A3B2CC'>
<cfoutput query="qVis">
	<form method="Post" name="form2" action="">
		<tr bgcolor="#scor#" class="texto">
		<cfset sdata = dateformat(qVis.Fer_Data,"dd/mm/yyyy")>
		<td height="21" class="texto style1"><div align="center"><span class="form">#sdata#</span>
		  <input name="frmdata2" type="hidden" id="frmdata2" value="#sdata#">
		</div></td>
		<td class="texto style1"><input name="frmdesc2" type="text" class="form" id="frmdesc2" value="#qVis.Fer_Descricao#" size="52" maxlength="50" vazio="false" nome="Nome">	  
		<span class="destaque">
		</span></td>
		<cfset sDiaSemana="">
		<cfset vDia=day(sdata)>
		<cfset vMes=month(sdata)>
		<cfset vAno=Year(sdata)>
		<cfset vData=CreateDate(vAno, vMes, vDia)>
		<cfset vDiaSem = DayOfWeek(vData)>
		<cfswitch expression="#vDiaSem#">
		  <cfcase value="1">
		    <cfset sDiaSemana = "Domingo">
		  </cfcase>
		  <cfcase value="2">
		    <cfset sDiaSemana = "Segunda-feira">
		  </cfcase>	
		  <cfcase value="3">
		    <cfset sDiaSemana = "Terça-feira">
		  </cfcase>
		  <cfcase value="4">
		    <cfset sDiaSemana = "Quarta-feira">
		  </cfcase>	
		  <cfcase value="5">
		    <cfset sDiaSemana = "Quinta-feira">
		  </cfcase>		  	  		  	  
		  <cfcase value="6">
		    <cfset sDiaSemana = "Sexta-feira">
		  </cfcase>		  
		  <cfdefaultcase>
		    <cfset sDiaSemana = "Sábado">
		  </cfdefaultcase>
		</cfswitch>
		<td class="texto style1"><span class="form">#sDiaSemana#</span></td>
		<td width="81" align="center" class="texto"><button name="submitAlt" type="button" class="botao" onClick="troca(frmdata2.value,frmdesc2.value,'alt');">Alterar Este</button></td>
		<td width="85" align="center" class="texto"><button name="submitExc" type="button" class="botao"  onClick="troca(frmdata2.value,'0','exc');">Excluir Este</button></td>
			
	</tr>
</form>
<cfif scor is 'A3B2CC'>
  <cfset scor = 'D7D7D7'>
<cfelse>
  <cfset scor = 'A3B2CC'>
</cfif>
  </cfoutput>
</table>

<form name="formx" method="POST" action="CFC/FeriadoNacional.cfc?method=IncFer">
  <input name="sfrmdata" type="hidden" id="sfrmdata">
  <input name="sfrmdesc" type="hidden" id="sfrmdesc">
  <input name="sacao" type="hidden" id="sacao">
</form>

<!--- Término da área de conteúdo --->
	</td></tr>
<!--- 	<tr>
	  <td height="2%" valign="bottom"><hr width="95%">
	  <div id="rodape"><cfinclude template="rodape.cfm"></div></td>
	</tr> --->
  </table>
</body>
</html>