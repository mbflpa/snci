<cfset exibenum = 1>
<!---Cria uma instância do componente Dao teste--->
	<cfobject component = "CFC/Dao" name = "dao">
<!---Invoca o metodo  rsUsuarioLogado para retornar dados do usuï¿½rio logado (rsUsuarioLogado)--->
	<cfinvoke component="#dao#" method="rsUsuarioLogado" returnVariable="rsUsuarioLogado">
 <!---Invoca o metodo  DescricaoPosArea para retornar a descriï¿½ï¿½o da lotaï¿½ï¿½o do usuï¿½rio logado (rsUsuarioLogado)--->       
    <cfinvoke component="#dao#" method="DescricaoPosArea" returnVariable="areaUsuarioLogado" CodigoDaUnidade ='#rsUsuarioLogado.CodigoLotacao#'>    

<cfquery name="rsGestoresAGF" datasource="#dsn_inspecao#">
    SELECT  DISTINCT  Areas.Ars_Codigo, Areas.Ars_Sigla
    FROM Unidades INNER JOIN Reops ON Unidades.Und_CodReop = Reops.Rep_Codigo INNER JOIN Areas ON Reops.Rep_CodArea = Areas.Ars_Codigo
    WHERE Unidades.Und_TipoUnidade=12 AND Areas.Ars_Codigo = '#rsUsuarioLogado.CodigoLotacao#'
</cfquery> 
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
    
function valida_form() {

  var frm = document.forms[0];
  if (frm.acao.value == 2)
     {
        
  	    if (frm.frmdtinic.value=='')
		{
		  alert('Informe a Data Inicial!');
		  frm.frmdtinic.focus();
		  return false;
		}
		if (frm.frmdtfim.value=='')
		{
		  alert('Informe a Data Final!');
		  frm.frmdtinic.focus();
		  return false;
		}
		if (frm.frmdtinic.value.length != 10)
		{
		alert("Preencher campo: Data Inicial ex. DD/MM/AAAA");
		return false;
	    }
		if (frm.frmdtfim.value.length!= 10)
		{
		alert("Preencher campo: Data Final ex. DD/MM/AAAA");
		return false;
	    }
        if(Right(frm.frmdtinic.value,4) != Right(frm.frmdtfim.value,4) && (frm.frmResp.value == 'S') ){
		   alert("Informe o período dentro do mesmo ano!");
           return false;
	    }
		/*if(Right(frm.frmdtinic.value,4) != Right(frm.frmdtfim.value,4) && (frm.frmResp.value == 'S') ){
		   alert("Informe o período dentro do mesmo ano!");
           return false;
	    }
        */
		var vDia = frm.frmdtinic.value.substr(0,2);
	    var vMes = frm.frmdtinic.value.substr(3,2);
	    var vAno = frm.frmdtinic.value.substr(6,10);
	    var dtini_yyyymmdd = vAno + vMes + vDia
		var vDia = frm.frmdtfim.value.substr(0,2);
	    var vMes = frm.frmdtfim.value.substr(3,2);
	    var vAno = frm.frmdtfim.value.substr(6,10);
	    var dtfim_yyyymmdd = vAno + vMes + vDia
		if (dtini_yyyymmdd > dtfim_yyyymmdd)
	     {
	       alert("Data Inicial maior que a data Final!");
	       return false;
	     }
         
       if(frm.frmResp.value == "")
          {
           alert("Selecione uma Situação!");
           return false;
          }  

           <cfif isDefined("Form.acao") and Form.acao neq "">
             <cfif Form.acao is 1>
               <cflocation url="itens_unidades_controle_respostas_area.cfm?ckTipo=#ckTipo#&dtinicial=&dtfinal=&frmResp=">
    
             <cfelseif Form.acao is 2>
               <cflocation url="itens_unidades_controle_respostas_area.cfm?ckTipo=#ckTipo#&dtinicial=#frmdtinic#&dtfinal=#frmdtfim#&frmResp=#frmResp#">
             </cfif>
           </cfif>

	   }
    
    
  } 
    

function Right(str, n){
    if (n <= 0)
       return "";
    else if (n > String(str).length)
       return str;
    else {
       var iLen = String(str).length;
       return String(str).substring(iLen, iLen - n);
    }
    if (a == "" ) 
   {
   alert("Selecionar a área ou órgão subordinador!");
   return false;
    }
}	
    

function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
		   if (data.value < 1 || data.value > 31) {
		      alert('Valor para o dia inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
		case 5:
			if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
		      alert('Valor para o Mês inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
	}
}
//=============================
//permite digitaï¿½ao apenas de valores numï¿½ricos
function numericos() {
var tecla = window.event.keyCode;
//permite digitaï¿½ï¿½o das teclas numï¿½ricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {

	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		event.returnValue = false;
	}
}
    
function exibe(a){
   
 document.getElementById('consultaSitData').style.visibility = 'hidden';
   if (a == 2) {
	document.getElementById('consultaSitData').style.visibility = 'visible';
 	
   }
 }

</script>
</head>

<body  onLoad="exibe(<cfoutput>#exibenum#</cfoutput>);">
<cfinclude template="cabecalho.cfm">
<p align="center">
  <!--- Ãrea de conteÃºdo   --->
</p>

<form action="itens_area_respostas_consulta_ref.cfm" method="post" onSubmit="return valida_form();" enctype="multipart/form-data"  target="_blank" name="frmopc" >
      <table width="44%" align="center">
	  <tr>
		
        <td>&nbsp;</td>
      </tr>
	  
      <tr>
        <td colspan="2"><p align="center" class="titulo1"><strong><br>
          PONTOS DE controle interno por &Aacute;REA</strong></p>
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
     
	   <div id="campos"></div>
     
	  <tr>
        <td>
         <span class="exibir">
          <strong><input name="ckTipo" type="radio" value="1" onClick="acao.value = 1; exibe(1)">Responder Itens da <cfoutput>#areaUsuarioLogado#</cfoutput></strong>
         </span>
        </td>
	   </tr>
	  
    
        <tr>
          <td><span class="exibir"><strong>
            <input name="ckTipo" type="radio" value="2" onClick="acao.value = 2; exibe(2)"> Consulta</strong></span></td>
		</tr>
        
		<tr>
          <td ><div id="consultaSitData" >
             <span class="exibir"><strong>&nbsp;&nbsp;&nbsp;Situação:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></span>
             <select name="frmResp" class="form" id="frmResp" >
                 <option value="" selected>Selecione uma Situação</option>
                <option value="N">NÃO SOLUCIONADOS</option>
                <option value="S">SOLUCIONADOS</option>
                <option value="A">APURAÇÃO</option> 
                <cfif rsGestoresAGF.recordcount gt 0 ><option value="R">REDE TERCEIRIZADA</option></cfif>
                <option value="C">CORPORATIVOS</option>
				<option value="E">ENCERRADOS</option>
             </select>
              <br>
              <br>
              <span class="exibir">===================== <strong>Ano Exerc&iacute;cio de Avalia&ccedil;&atilde;o</strong> ========================== </span><br>
              <br>
             <cfset inic = '01/01/' & year(now())>
		     <cfset fim = '31/12/' & year(now())> 
             <span class="exibir"><strong>&nbsp;&nbsp;Data Inicial:&nbsp;</strong> </span>
             <strong class="titulo1"><input name="frmdtinic" type="text" class="form" id="frmdtinic" tabindex="1"  size="13" maxlength="10" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" value="<cfoutput>#inic#</cfoutput>"></strong> 
             <span class="exibir"><strong>&nbsp;&nbsp;Data Final:&nbsp;</strong> </span>
             <strong class="titulo1"><input name="frmdtfim" type="text" class="form" id="frmdtfim" tabindex="2" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="13" maxlength="10"  value="<cfoutput>#fim#</cfoutput>"></strong> 
            </div>
          </td>
        </tr>
        <tr>
           <td>&nbsp;</td>
        </tr>
      <tr>
        <tr>
        <td><div align="center">
          <input name="Confirmar" type="submit" class="exibir" id="Confirmar" value="Confirmar" >
        </div></td>
		</tr>
  </table>
  <input name="acao" type="hidden">
</form>
</body>
</html>