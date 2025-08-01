<cfprocessingdirective pageEncoding ="utf-8"/>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena 
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="qArea" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso
FROM Usuarios
GROUP BY Usu_GrupoAcesso
HAVING (((Usu_GrupoAcesso)<>'DESENVOLVEDORES'))
</cfquery>

<!--- area de registros em banco --->
<cfif isDefined("form.frm1_acao") and form.frm1_acao is "anexar">
	
		<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">

		<cfset data = DateFormat(now(),'YYYYMMDD') & '_' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'm' & TimeFormat(Now(),'SS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>

		<!--- <cfset destino = cffile.serverdirectory & '\' & form.frm1_ano & form.frm1_id & '_' & data & '_' & right(CGI.REMOTE_USER,8) & '.pdf'> --->
		<cfset destino = form.frm1_ano & form.frm1_id & '_' & data & '_' & right(CGI.REMOTE_USER,8) & '.pdf'>


		<cfif FileExists(origem)>

			<cffile action="rename" source="#origem#" destination="#destino#">

			<cfquery datasource="#dsn_inspecao#">
			UPDATE AvisosGrupos SET AVGR_ANEXO = '#destino#', AVGR_dtultatu = convert(char, getdate(), 102), AVGR_username = '#CGI.REMOTE_USER#'
			WHERE AVGR_ANO = '#form.frm1_ano#' AND AVGR_ID = #form.frm1_id#
			</cfquery>
       </cfif>
  </cfif>

<cfif isDefined("form.frm1_acao") and form.frm1_acao is "excluiranexo">

       <cfquery name="rsCaminho" datasource="#dsn_inspecao#">
		select AVGR_ANEXO from AvisosGrupos 
		WHERE AVGR_ANO = '#form.frm1_ano#' AND AVGR_ID = #form.frm1_id#
		</cfquery>

	   <cfquery datasource="#dsn_inspecao#">
		UPDATE AvisosGrupos SET AVGR_ANEXO = '', AVGR_dtultatu = convert(char, getdate(), 102), AVGR_username = '#CGI.REMOTE_USER#'
		WHERE AVGR_ANO = '#form.frm1_ano#' AND AVGR_ID = #form.frm1_id#
	   </cfquery>  
		<!--- Exluindo arquivo do diretorio de Anexos --->
			<cffile action="delete" file="#diretorio_anexos##rsCaminho.AVGR_ANEXO#">
<!--- 		<cfoutput>#diretorio_anexos##rsCaminho.AVGR_ANEXO#</cfoutput> --->
</cfif>

<cfif isDefined("form.frm1_acao") and form.frm1_acao is "inc">
 	<cfset dtinic = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dtfina = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dtinic = dateformat(form.dtinic,"DD/MM/YYYY")>
	<cfset dtfina = dateformat(form.dtfim,"DD/MM/YYYY")>

  	<cfquery datasource="#dsn_inspecao#" name="rsMax">
	SELECT Max(AVGR_ID) AS maxID 
	FROM AvisosGrupos 
	WHERE AVGR_ANO = year(getdate())
	</cfquery>

    <cfif rsMax.RecordCount lte 0 OR rsMax.maxID IS "">
	 <cfset auxmaxid = 1>
	<cfelse>
	 <cfset auxmaxid = rsMax.maxID + 1>	 
	</cfif>
	<cfquery datasource="#dsn_inspecao#">
		 INSERT AvisosGrupos(AVGR_ANO, AVGR_ID, AVGR_DT_INICIO, AVGR_DT_FINAL, AVGR_GRUPOACESSO, AVGR_AVISO, AVGR_DTULTATU, AVGR_DT_CAD, AVGR_USERNAME, AVGR_STATUS, AVGR_TITULO)
		 VALUES (year(getdate()), #auxmaxid#, #createodbcdate(createdate(year(dtinic),month(dtinic),day(dtinic)))#,#createodbcdate(createdate(year(dtfina),month(dtfina),day(dtfina)))#,'#frmgrupo#','#frmmensagem#',convert(char, getdate(), 102),convert(char, getdate(), 102),'#CGI.REMOTE_USER#', '#frmsituacao#','#titulo#')
	</cfquery>
	
	<!--- Inserir anexo no momento da inclusão é opcional --->
	<cfif len(trim(arquivo)) gt 0>
	    <cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">

		<cfset data = DateFormat(now(),'YYYYMMDD') & '_' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'm' & TimeFormat(Now(),'SS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>

		<cfset destino = cffile.serverdirectory & '\' & form.frm1_ano & #auxmaxid# & '_' & data & '_' & right(CGI.REMOTE_USER,8) & '.pdf'>


		<cfif FileExists(origem)>

			<cffile action="rename" source="#origem#" destination="#destino#">

			<cfquery datasource="#dsn_inspecao#">
			UPDATE AvisosGrupos SET AVGR_ANEXO = '#destino#', AVGR_dtultatu = convert(char, getdate(), 102), AVGR_username = '#CGI.REMOTE_USER#'
			WHERE AVGR_ANO = year(getdate()) AND AVGR_ID = #auxmaxid#
			</cfquery>
       </cfif>
	</cfif>	   
	<!---  --->
	
</cfif>
<!--- desligar aviso --->
<cfif isDefined("form.frmx_sacao") and form.frmx_sacao is "des">
	<cfquery datasource="#dsn_inspecao#">
UPDATE AvisosGrupos SET AVGR_status = 'D', AVGR_DT_DES = convert(char, getdate(), 102), AVGR_dtultatu = convert(char, getdate(), 102), AVGR_username = '#CGI.REMOTE_USER#'
WHERE AVGR_ANO = '#form.frmx_ano#' AND AVGR_ID = #form.frmx_id#
	</cfquery>
</cfif>
<!--- ativar aviso --->
<cfif isDefined("form.frmx_sacao") and form.frmx_sacao is "ati">
	<cfquery datasource="#dsn_inspecao#">
UPDATE AvisosGrupos SET AVGR_status = 'A', AVGR_DT_ATI = convert(char, getdate(), 102), AVGR_dtultatu = convert(char, getdate(), 102), AVGR_username = '#CGI.REMOTE_USER#'
WHERE AVGR_ANO = '#form.frmx_ano#' AND AVGR_ID = #form.frmx_id#
	</cfquery>
</cfif>
<!--- excluir aviso (exclusão lógica)) --->
<cfif isDefined("form.frmx_sacao") and form.frmx_sacao is "exc">
	<cfquery datasource="#dsn_inspecao#">
	UPDATE AvisosGrupos SET AVGR_status = 'E', AVGR_DT_EXC = convert(char, getdate(), 102), AVGR_dtultatu = convert(char, getdate(), 102), AVGR_username = '#CGI.REMOTE_USER#'
	WHERE AVGR_ANO = '#form.frmx_ano#' AND AVGR_ID = #form.frmx_id#
	</cfquery>
</cfif>
<!--- fim area de registros em banco --->
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
//=============================
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
//permite digitaçao apenas de valores numéricos
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	
	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		//alert(tecla);
	//  if () {
		event.returnValue = false;
	 // }
	}
//}
}
//=============================
//           A           B            C              D                      E                F                      G
//onClick="incluir(dtinic.value,dtfim.value,frmgrupo.value,titulo.value,frmmensagem.value,'avisosgrupos_geral.cfm','inc')">Incluir</button>
function incluir(a,b,c,d,e,f,g){
   document.form1.frm1_acao.value=g;
}
//=============================
function func_anexar(a,b,c,d,e){
//                          a            b                   c                      d            e
//onClick="func_anexar('#AVGR_ANO#','#AVGR_ID#','index.cfm?opcao=permissao15','#AVGR_ANEXO#','anexar');">
//alert(a + b + c + d + e);
//return false;

if (document.form1.arquivo.value == '')
{
	  alert('Você deve informar o caminho do arquivo a ser anexado!');
	  document.form1.arquivo.focus();
	  return false;
}
    document.form1.frm1_ano.value=a;
	document.form1.frm1_id.value=b;
	document.form1.action=c;
	document.form1.frm1_caminho.value=d;
	document.form1.frm1_acao.value=e;
	document.form1.submit(); 
}
//=============================
function func_abriranexo(a,b,c,d,e){
//onClick="window.open('abrir_pdf_act.cfm?arquivo=#arquivo#','_blank')"
//<input name="frm1_acao" type="hidden" id="frm1_acao">
//<input name="frm1_ano" type="hidden" id="frm1_ano" value="">
//<input name="frm1_id" type="hidden" id="frm1_id" value="">
//<input name="frm1_caminho" type="hidden" id="frm1_caminho" value="">
//<input name="frm1dthoje" type="hidden" id="frm1dthoje" value="#dateformat(now(),"YYYYMMDD")#">	
//                                 a            b                  c                      d               e
// onClick="func_excluiranexo('#AVGR_ANO#','#AVGR_ID#','index.cfm?opcao=permissao15','#AVGR_ANEXO#','excluiranexo');">Exc(Anexo)</button>
//alert(a + b + c);
//return false;
    document.form1.frm1_ano.value=a;
	document.form1.frm1_id.value=b;
	document.form1.action=c;
	document.form1.frm1_caminho.value=d;
	document.form1.frm1_acao.value=e;
	document.form1.submit(); 
}



//=============================
function func_excluiranexo(a,b,c,d,e){
//<input name="frm1_acao" type="hidden" id="frm1_acao">
//<input name="frm1_ano" type="hidden" id="frm1_ano" value="">
//<input name="frm1_id" type="hidden" id="frm1_id" value="">
//<input name="frm1_caminho" type="hidden" id="frm1_caminho" value="">
//<input name="frm1dthoje" type="hidden" id="frm1dthoje" value="#dateformat(now(),"YYYYMMDD")#">	
//                                 a            b                  c                      d               e
// onClick="func_excluiranexo('#AVGR_ANO#','#AVGR_ID#','index.cfm?opcao=permissao15','#AVGR_ANEXO#','excluiranexo');">Exc(Anexo)</button>
//alert(a + b + c);
//return false;
    document.form1.frm1_ano.value=a;
	document.form1.frm1_id.value=b;
	document.form1.action=c;
	document.form1.frm1_caminho.value=d;
	document.form1.frm1_acao.value=e;
	document.form1.submit(); 
}
//=============================
function func_desati(a,b,c,d){
//alert(a + b + c);
//return false;
    document.formx.frmx_ano.value=a;
	document.formx.frmx_id.value=b;
	document.formx.action=c;
	document.formx.frmx_sacao.value=d;
	document.formx.submit(); 
}
//=============================
function alterar(a,b,c,d){
//alert(a + b + c + d);
//return false;
	document.formx.frmx_ano.value=a;
	document.formx.frmx_id.value=b;
	document.formx.action=c;
	document.formx.frmx_sacao.value=d;
	document.formx.submit(); 
}



//========================
function valida_form() {
//alert('dtfim');
//return false;
var frm = document.forms[0];

if (frm.dtinic.value == ''){
	  alert('Informe a Data Inicial!');
	  frm.dtinic.focus();
	  return false;
}
if (frm.dtfim.value == ''){
	  alert('Informe a Data Final!');
	  frm.dtinic.focus();
	  return false;
	}
if (frm.dtinic.value.length != 10){
	alert("Preencher campo: Data Inicial ex. DD/MM/AAAA");
	return false;
	}
if (frm.dtfim.value.length != 10){
	alert("Preencher campo: Data Final ex. DD/MM/AAAA");
	return false;
	}	

var dtini_yyyymmdd = frm.dtinic.value;
var dtfin_yyyymmdd = frm.dtfim.value;

var diai = dtini_yyyymmdd.substr(0,2);
var mesi = dtini_yyyymmdd.substr(3,2);
var anoi = dtini_yyyymmdd.substr(6,10);
var dtini_yyyymmdd = anoi + mesi + diai;

var diaf = dtfin_yyyymmdd.substr(0,2);
var mesf = dtfin_yyyymmdd.substr(3,2);
var anof = dtfin_yyyymmdd.substr(6,10);
var dtfin_yyyymmdd = anof + mesf + diaf;
//alert(dtini_yyyymmdd + ' ' + dtfin_yyyymmdd);

 if (frm.frm1dthoje.value > dtini_yyyymmdd)
 {
	alert("Data Inicial é menor que a data do dia!")
	frm.dtinic.focus();
	return false
 }
 
 if (frm.frm1dthoje.value > dtfin_yyyymmdd)
 {
	alert("Data Final é menor que a data do dia!")
	frm.dtfim.focus();
	return false
 }
 
  if (dtini_yyyymmdd > dtfin_yyyymmdd)
 {
	alert("Data Inicial é maior que a data Final!")
	frm.dtinic.focus();
	return false
 }

//==============================
var auxmesinic = Math.round(mesi);
auxmesinic--
var auxmesfina = Math.round(mesf);
auxmesfina--
 
var totfimsem = 0;
var one_day = 1000 * 60 * 60 * 24
var inicial_date = new Date(anoi, auxmesinic, diai);
var final_date = new Date(anof, auxmesfina, diaf);

var Result = Math.round(final_date.getTime() - inicial_date.getTime()) / (one_day);
var Final_Result = Result.toFixed(0);
var datavariar = inicial_date;
for (x = 0 ; x <= Final_Result ; x++)
    {
	if (datavariar.getDay() == 0 || datavariar.getDay() == 6)
	{ 
	totfimsem++
	}
	datavariar.setDate(datavariar.getDate() + 1)
	 }

if ((Final_Result - totfimsem) > 10){
	  alert('O período de vigência (Data Inicial - Data Final) não pode exceder os 10(dez) dias úteis');
	  frm.dtinic.focus();
	  return false;
}
//==============================
if (frm.frmgrupo.value == ''){
  alert('Favor informar o Grupo de Acesso!');
  frm.frmgrupo.focus();
  return false;
}

if (frm.titulo.value == ''){
  alert('Favor informar Titulo!');
  frm.titulo.focus();
  return false;
}

if (frm.frmmensagem.value == ''){
  alert('Favor informar Mensagem!');
  frm.frmmensagem.focus();
  return false;
}


//return false;
}
</script>
<script language="JavaScript" src="../../mm_menu.js"></script>
	</head>

<body>
<!--- <cfinclude template="index.cfm"> --->
<!--- <cfinclude template="cabecalho.cfm"> --->
	<form name="form1" method="post" action="index.cfm?opcao=permissao15" onSubmit="return valida_form()" enctype="multipart/form-data">
<table width="98%" border="0" align="center">
          <tr valign="baseline">
            <td class="exibir"><div align="center"><span class="titulo1"><strong>AVISOS - SNCI </strong></span></div></td>
          </tr>
          <tr valign="baseline">
            <td><span class="titulos">Data Inicial  </span></td>
          </tr>
      
            <tr valign="baseline">
              <td><input name="dtinic" type="text" class="form" tabindex="1" id="dtinic" size="14" maxlength="10"  onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)"></td>
            </tr>
            <tr valign="baseline">
              <td><span class="titulos">Data Final  </span></td>
            </tr>
            <tr valign="baseline">
              <td><input name="dtfim" type="text" class="form" id="dtfim" tabindex="2" onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)" size="14" maxlength="10"></td>
            </tr>
         
          <tr valign="baseline">
            <td><span class="titulos">Grupo de Acesso </span></td>
          </tr>
          <tr valign="baseline">
            <td>
			<select name="frmgrupo" id="frmgrupo" class="form">
			   <option value="">--------------------------</option>
		       <option value="GERAL">GERAL</option>
			   <option value="GESTORINSPETOR">GESTORES/INSPETORES</option>
			   <option value="GESTORINSPETORANALISTA">GESTORES/INSPETORES/ANALISTAS</option>
			   <option value="">--------------------------</option>
	          <cfoutput query="qArea"> 
			    <option value="#UCase(Usu_GrupoAcesso)#">#UCase(Usu_GrupoAcesso)#</option>
	          </cfoutput>
	        </select>			 </td>
    </tr>

          <tr valign="baseline">
            <td><span class="titulos">Título </span></td>
          </tr>
          <tr valign="baseline">
            <td><input name="titulo" type="text" class="form" id="titulo" tabindex="2" size="120" maxlength="100"></td>
          </tr>
          <tr valign="baseline">
            <td><span class="titulos">Mensagem</span></td>
          </tr>
            <tr valign="baseline">
              <td>
			  <label>
            <textarea name="frmmensagem" cols="168" rows="12" class="titulos" id="frmmensagem"></textarea>
          </label>			  </td>

  
          <!--- ÁREA DE CONTEÚDO --->
            <tr valign="baseline">
              <td><table width="1045" height="25" border="0" align="left">
                <tr>
                  <td width="62"><span class="titulos">Situação:</span></td>
                  <td width="973"><select name="frmsituacao" id="frmsituacao" class="form">
                    <option value="A">Ativado</option>
                    <option value="D" selected="selected">Desativado</option>
                  </select></td>
                </tr>
              </table></td>
            </tr>
            <tr valign="baseline">
              <td><hr></td>
            </tr>
          <tr valign="baseline">
            <td><table width="100%" height="19" border="0">

                <tr>
                  <td colspan="2">
                    
                    <div align="center">
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <button type="Submit" class="botao" onClick="incluir(dtinic.value,dtfim.value,frmgrupo.value,titulo.value,frmmensagem.value,'avisosgrupos_geral.cfm','inc')">Incluir(Aviso)</button>
                    </div></td>
                </tr>
            <tr valign="baseline">
              <td colspan="2"><hr></td>
            </tr>				
				<tr>
                  <td colspan="2">&nbsp;</td>
                </tr>
				          <tr bgcolor="#eeeeee">
        <td colspan="2" bgcolor="eeeeee" class="exibir"><div align="center"><strong class="exibir">Seleção de arquivo para anexar ao aviso</strong> </div></td>
      </tr>
      <tr>
        <td width="17%" bgcolor="eeeeee" class="exibir"><strong class="exibir">Caminho do  arquivo (PDF) :</strong></td>
        <td width="83%" bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="100"></td>
        </tr>	
            </table></td>
          </tr>
          <tr valign="baseline">
            <td><hr></td>
          </tr>
      </table>
	<input name="frm1_acao" type="hidden" id="frm1_acao">
	<input name="frm1_ano" type="hidden" id="frm1_ano" value="">
	<input name="frm1_id" type="hidden" id="frm1_id" value="">
	<input name="frm1_caminho" type="hidden" id="frm1_caminho" value="">
	<input name="frm1dthoje" type="hidden" id="frm1dthoje" value="<cfoutput>#dateformat(now(),"YYYYMMDD")#</cfoutput>">		
</form>
 <!--- desabilitar vigência vencida --->
	<cfquery datasource="#dsn_inspecao#">
		UPDATE AvisosGrupos SET AVGR_status = 'D' WHERE  AVGR_status = 'A' and AVGR_DT_FINAL < convert(datetime,convert(char(10),GETDATE(),102) + ' 00:00')
	</cfquery> 
<!---  --->
	<cfquery name="rsAvisos" datasource="#dsn_inspecao#">
	SELECT AVGR_ANO, AVGR_ID, AVGR_DT_INICIO, AVGR_DT_FINAL, AVGR_GRUPOACESSO, AVGR_AVISO, AVGR_status, AVGR_username, AVGR_TITULO, AVGR_ANEXO
	FROM AvisosGrupos
	<!--- where (AVGR_ID = 8 or AVGR_ID = 10) --->
	ORDER BY AVGR_ANO DESC, AVGR_ID desc, AVGR_DT_INICIO DESC,AVGR_status
	</cfquery>
	  <table width="100%" border="0" align="center">
	  <tr class="titulosClaro">
	    <td colspan="16" bgcolor="eeeeee" class="exibir">Qtd.: <cfoutput>#rsAvisos.recordCount#</cfoutput></td>
    </tr>
	    <tr bgcolor="#B4B4B4" class="exibir" align="center">
	  	<td width="5%"><div align="center">Ano/Num </div></td>
		<td width="5%"><div align="left">Data Inicial</div></td>
		<td width="5%"><div align="center">Data Final </div></td>
		<td width="11%"><div align="left">Grupo Acesso </div></td>
		<td width="16%" bgcolor="#B4B4B4"><div align="left">Título</div></td>
		<td width="17%"><div align="left">Avisos</div></td>
		<td><div align="left">Status</div></td>
		<td>Usuário</td>
		<td colspan="5">Ação</td>
		</tr>

  
	      <cfset scor = 'f7f7f7'>
		  <cfoutput query="rsAvisos">
 		     <form action="" method="POST" name="formexc">
                <cfif len(AVGR_ID) is 1>
					<cfset auxid = '000' & AVGR_ID>
				<cfelseif len(AVGR_ID) is 2>
					<cfset auxid = '00' & AVGR_ID>
				<cfelseif len(AVGR_ID) is 3>
					<cfset auxid = '0' & AVGR_ID>		
				</cfif>
				<cfset habtnexc = ''>
				 <cfif AVGR_status eq 'D' or AVGR_status eq 'E'>
				 	<cfset habtnexc = 'disabled'>
				 </cfif>
				 <cfset auxanoid = AVGR_ANO & '/' & auxid>			 
				 <cfset auxdtini = dateformat(AVGR_DT_INICIO,"DD/MM/YYYY")>
				 <cfset auxdtfim = dateformat(AVGR_DT_FINAL,"DD/MM/YYYY")>
				 <cfset habtnA = ''>
				 <cfif dateformat(AVGR_DT_FINAL,"YYYYMMDD") lt dateformat(now(),"YYYYMMDD")>
				 <!--- <cfif AVGR_status neq 'A'> --->
				 	<cfset habtnA = 'disabled'>
					<!--- <cfset habtnexc = 'disabled'> --->
				 </cfif>
				 				 
				 <cfset auxst = AVGR_status>
				  <tr valign="middle" bgcolor="#scor#" class="exibir"><td bgcolor="#scor#"><div align="center">#auxanoid#</div></td>
				    <td bgcolor="#scor#">#auxdtini#</td>
				    <td><div align="center">#auxdtfim#</div></td>

					<td><div align="left">#AVGR_GRUPOACESSO#</div></td>
					<td width="16%">#AVGR_TITULO#</td>
						<td width="17%">#left(AVGR_AVISO,40)#</td>
					<td width="4%"><div align="center">#auxst#</div></td>
						<cfset auxmatr = right(AVGR_username,8)>
						<td width="5%">#auxmatr#</td>
						<td width="5%"><div align="center">
						  <button name="submitAlt" type="button" class="botao" onClick="alterar('#AVGR_ANO#','#AVGR_ID#','Avisosgrupos_alt.cfm','alt');" #habtnA#>
					      Alterar</button>
				    </div></td>
					<td width="9%">
					<cfif len(AVGR_ANEXO) lte 0>
						<div align="center">
			<button name="submitAlt" type="button" class="botao" onClick="func_anexar('#AVGR_ANO#','#AVGR_ID#','index.cfm?opcao=permissao15','#AVGR_ANEXO#','anexar');" #habtnA#>
						  Anexar</button>
						  <cfset habtnB = 'disabled'>
					<cfelse>
			<button name="submitAlt" type="button" class="botao" onClick="func_excluiranexo('#AVGR_ANO#','#AVGR_ID#','index.cfm?opcao=permissao15','#AVGR_ANEXO#','excluiranexo');" #habtnA#>
						  Excluir(Anexo)</button>	
						  <cfset habtnB = ''>					  
			        </div>
					</cfif>					</td>	
			
					<!--- <cfset auxcaminho = mid(AVGR_ANEXO, 36, len(AVGR_ANEXO))> --->
					<!--- smeio#auxcaminho# --->
					<td width="7%">
					<div align="center">
					   <input type="button" class="botao" name="Abrir" value="Abrir Anexo" onClick="window.open('abrir_pdf_act.cfm?arquivo=#AVGR_ANEXO#','_blank')" #habtnB#>
					</div>					</td>																
						<td width="7%">
						<div align="center">
						<cfif auxst eq 'A'>
						   <button name="submitAlt" type="button" class="botao" onClick="func_desati('#AVGR_ANO#','#AVGR_ID#','index.cfm?opcao=permissao15','des');" #habtnA#>
						  Desativar</button>
						  <cfelse>
						   <button name="submitAlt" type="button" class="botao" onClick="func_desati('#AVGR_ANO#','#AVGR_ID#','index.cfm?opcao=permissao15','ati');" #habtnA#>
						  Ativar</button>						  
						</cfif>
			        </div>		
					</td>
<td width="4%"><button name="submitAlt" type="button" class="botao" onClick="func_desati('#AVGR_ANO#','#AVGR_ID#','index.cfm?opcao=permissao15','exc');" #habtnexc#>Excluir</button></td>
			  </tr>
			  <input type="hidden" name="AVGRID" value="#AVGR_ID#">
		    </form>
			<cfif scor eq 'f7f7f7'>
		      <cfset scor = 'CCCCCC'>
			<cfelse>
		      <cfset scor = 'f7f7f7'>
			</cfif>
 		  </cfoutput>
<!---	  </cfif> --->
</table>

	<!--- FIM DA ÁREA DE CONTEÚDO --->

	</table>
 </form>   
<cfoutput>
<form name="formvolta" method="post" action="index.cfm?opcao=permissao15">
  <input name="sacao" type="hidden" id="sacao" value="voltar">
</form> 

<form name="formx" method="POST" action="index.cfm?opcao=permissao15">
  <input name="frmx_ano" type="hidden" id="frmx_ano" value="">
  <input name="frmx_id" type="hidden" id="frmx_id" value="">
  <input name="frmx_sacao" type="hidden" id="frmx_sacao">
</form>
</cfoutput>
  <!--- Término da área de conteúdo --->
</body>
</html>
