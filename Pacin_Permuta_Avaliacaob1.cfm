<cfprocessingdirective pageEncoding ="utf-8"/>
<!---  <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> --->         

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena
	FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
	WHERE Usu_DR = '#form.frmse#'
</cfquery> 

<!---  --->
<cfoutput>
<cfif isDefined("Form.sacao") and #form.sacao# is 'alt'>
			<cfset parecer = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Deferimento de Permuta de Avaliação no PACIN' & CHR(13) & CHR(13) & 'À(O) DCINT/GCOP/SGCIN/SCOI' & CHR(13) & CHR(13) & 'Em deferimento a sua solicitação relativo a permuta de Avaliação no PACIN ' & #Form.frmano# & ' entre as unidades de: ' & #frmunidde# & ' - ' & #frmuniddedesc# & ' para: ' & #frmunidpara# & ' - ' & #frmunidparadesc# & ' junto ao sistema SNCI.' & CHR(13) & 'Segue o deferimento da solicitação como: ' & #form.frmmotivo#  & CHR(13) & 'Detalhes do deferimento: ' & #form.frmdescoutros# & CHR(13) & CHR(13) &  'Responsável: ' & #CGI.REMOTE_USER# & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------' & CHR(13) & CHR(13) & #form.frmpareceratu#>		  
			<cfquery datasource="#dsn_inspecao#" name="qVerifica">
			 update PacinPermutaUnidade set PPU_Motivo='#Form.frmmotivo#'
			 ,PPU_Parecer='#parecer#'
			 ,PPU_Status='#form.frmdeferimento#'
			 ,PPU_dtultatu=CONVERT(char, GETDATE(), 120)
			 ,PPU_username='#CGI.REMOTE_USER#'		
			 WHERE PPU_Ano='#Form.frmano#' and PPU_DEUnidade='#Form.frmunidde#' and PPU_PARAUnidade='#Form.frmunidpara#'
			</cfquery>	 
		<!---  --->
		<cfif form.frmdeferimento eq 'C'>
		   <cfquery datasource="#dsn_inspecao#">
			UPDATE Unidades set Und_Ano_Avaliar = '#form.frmano#'
			where Und_Codigo = '#Form.frmunidpara#' 
		   </cfquery> 
		   <!---  --->
			<cfquery name="rsAval" datasource="#dsn_inspecao#">		
				SELECT top 1 INP_NumInspecao
				FROM Inspecao
				WHERE INP_Unidade = '#Form.frmunidde#'
				order by INP_NumInspecao desc
			</cfquery>
			<cfset auxano = right(rsAval.INP_NumInspecao,4)>
 			<cfquery datasource="#dsn_inspecao#">
				UPDATE Unidades set Und_Ano_Avaliar = '#auxano#'
				where Und_Codigo = '#Form.frmunidde#' 
			</cfquery>  
		</cfif>		
		<!---  --->
			<cfset corpo = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Deferimento de Permuta de Avaliação no PACIN' & CHR(13) & CHR(13) & 'À(O) DCINT/GCOP/SGCIN/SCOI' & CHR(13) & CHR(13) & 'Em deferimento a sua solicitação relativo a permuta de Avaliação no PACIN ' & #Form.frmano# & ' entre as unidades de: ' & #frmunidde# & ' - ' & #frmuniddedesc# & ' para: ' & #frmunidpara# & ' - ' & #frmunidparadesc# & ' junto ao sistema SNCI.' & CHR(13) & 'Segue o deferimento da solicitação como: ' & #form.frmmotivo#  & CHR(13) & 'Detalhes do deferimento: ' & #form.frmdescoutros# & CHR(13) & CHR(13) &  'Responsável: ' & #CGI.REMOTE_USER#>
			<cfmail from="SNCI@correios.com.br" to=#form.frmemailretorno# subject="Solicitação por Permuta de Avaliação" type="HTML">
				 Mensagem automática. Não precisa responder!<br><br>
				<strong>
				  #corpo#<br><br>
				  &nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
				</strong>
			</cfmail>	
				
		<!---  --->
     <cflocation url="Pacin_Permuta_Avaliacaob.cfm?frmse=#form.frmse#&frmano=#form.frmano#"> 
</cfif>
</cfoutput> 

<cfoutput>
	<cfquery name="rsPermuta" datasource="#dsn_inspecao#">
		SELECT PPU_DEUnidade, Unidades.Und_Descricao, Unidades.Und_Ano_Horas_Avaliar, Unidades.Und_Ano_Pontos_Avaliar, PPU_PARAUnidade, Unidades_1.Und_Descricao as unidparadesc, Unidades_1.Und_Ano_Horas_Avaliar as hh, Unidades_1.Und_Ano_Pontos_Avaliar as pto, PPU_username, PPU_Parecer, PPU_Motivo
		FROM Unidades AS Unidades_1 
		INNER JOIN (PacinPermutaUnidade 
		INNER JOIN Unidades ON PPU_DEUnidade = Unidades.Und_Codigo) ON Unidades_1.Und_Codigo = PPU_PARAUnidade
		
		WHERE PPU_Ano ='#form.frmano#' and PPU_Status = 'S' and PPU_DEUnidade = '#form.frmunidde#'
	</cfquery>
	<!---  --->
	
	<cfquery name="rsEmail" datasource="#dsn_inspecao#">
		SELECT Usu_GrupoAcesso, Usu_Email
		FROM Usuarios  
		WHERE Usu_Login = '#rsPermuta.PPU_username#'
	</cfquery>	 
	<cfquery name="rsAnexo" datasource="#dsn_inspecao#">
		SELECT PPU_Anexo
		FROM PacinPermutaUnidade
		WHERE PPU_DEUnidade='#form.frmunidde#' and PPU_PARAUnidade='#form.frmunidpara#' and PPU_Ano='#form.frmano#'
	</cfquery>
</cfoutput>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">

<script language="JavaScript" src="../../mm_menu.js"></script>
<script type="text/javascript">
function validaForm() {
	if (document.form1.sacao.value == 'alt'){
	    var sfrmmotivo = document.form1.frmmotivo.value;

		var sfrmdescoutros = document.form1.frmdescoutros.value;
		if (sfrmdescoutros == ''){
		   alert('Caro Usuário, falta especificar a motivação deste Deferimento!');
		   return false;
		   }

   		var auxcam = '\n\nConfirmar Deferimento de permuta?';

		
		if (confirm ('            Atenção!' + auxcam))
		{
			 return true;
		}
		else
		   {
			 document.form1.sacao.value='';
			 return false;
		  }
		}
//return false;
}
//================
function voltar(){
    document.formvolta.submit();
 }
</script>
	<style type="text/css">
<!--
.style1 {color: #FFFFFF}
-->
    </style>
	</head>

<body>


<cfinclude template="cabecalho.cfm">
	    <span class="exibir"><strong>
	    </strong></span>
        <table width="58%" border="0" align="center">
          <tr valign="baseline">
            <td colspan="6" class="exibir">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6" class="exibir"><div align="center"><strong>AUTORIZAR SUBSTITUIÇÃO DE UNIDADE PARA AVALIAÇÃO NO PACIN</strong></div></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6">&nbsp;</td>
          </tr>
	  
          <cfoutput>
            <tr valign="baseline">
              <td width="14%"><div align="right"><span class="titulos">Superintendência:</span></div></td>
              <td width="17%"><div align="left">
                <select name="dr" id="dr" class="form" disabled>
                  <option selected="selected" value="#qAcesso.Usu_DR#">#qAcesso.Dir_Sigla#</option>
                </select>
              </div></td>

              <td width="6%"><div align="right"><span class="titulos">Exercício:</span></div></td>
              <td width="17%"><div align="left">
                <select name="frmano" id="frmano" class="form"" disabled>
                  <option value="#frmano#">#frmano#</option>
                </select>
              </div></td>
            </tr>
          </cfoutput>
</table>

	    <table width="55%" border="0" align="center">
          <form action="Pacin_Permuta_Avaliacaob1.cfm" method="post" target="_parent" name="form1" onSubmit="return validaForm()">
            <tr bgcolor="f7f7f7">
              <td colspan="9" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
            </tr>
            <tr bgcolor="f7f7f7">
              <td colspan="9" align="center" bgcolor="#CCCCCC" class="titulo1"> Unidade SOLICITADA PARA PERMUTAREM NO PACIN de <cfoutput>#form.frmano#</cfoutput></td>
            </tr>

                  <tr bgcolor="#CCCCCC" class="titulos">
                    <td width="6%">&nbsp;</td>
                    <td width="23%">Cód. Unidade</td>
                    <td width="39%" bgcolor="#CCCCCC">Nome da Unidade </td>
                    <td width="5%" bgcolor="#CCCCCC"><div align="center">Horas</div></td>
                    <td width="5%" bgcolor="#CCCCCC"><div align="center">Pontos</div></td>
                    <td width="22%" bgcolor="#CCCCCC">Motivo</td>
                  </tr>

                      <tr class="titulos" bgcolor="f7f7f7">
                        <td bgcolor="#FF3300"><span class="style1">DE &nbsp;&nbsp; &nbsp;&nbsp;:</span></td>
                        <td><cfoutput>#rsPermuta.PPU_DEUnidade#</cfoutput></td>
                        <td><cfoutput>#rsPermuta.Und_Descricao#</cfoutput></td>
						<cfset horas = rsPermuta.Und_Ano_Horas_Avaliar>
                        <td><div align="center"><cfoutput>#horas#</cfoutput></div></td>
						<cfset pontos = numberFormat(rsPermuta.Und_Ano_Pontos_Avaliar,99.00)>
                        <td><div align="center"><cfoutput>#pontos#</cfoutput></div></td>
                        <td bgcolor="#FF3300"><cfoutput><span class="style1">#rsPermuta.PPU_Motivo#</span></cfoutput></td>
            </tr>
					  <tr class="titulos" bgcolor="#EEEEEE">
                        <td bgcolor="#33CCFF">PARA:</td>
                        <td><cfoutput>#rsPermuta.PPU_PARAUnidade#</cfoutput></td>
                        <td bgcolor="#EEEEEE"><cfoutput>#rsPermuta.unidparadesc#</cfoutput></td>
						<cfset horas = rsPermuta.hh>
                        <td bgcolor="#EEEEEE"><div align="center"><cfoutput>#horas#</cfoutput></div></td>
						<cfset pontos = numberFormat(rsPermuta.pto,99.00)>
                        <td bgcolor="#EEEEEE"><div align="center"><cfoutput>#pontos#</cfoutput></div></td>
                        <td bgcolor="#EEEEEE">&nbsp;</td>
		    </tr>
                      <tr>
                        <td colspan="9">&nbsp;</td>
                      </tr>
                      
            <tr bgcolor="#EEEEEE" class="titulos">
              <td colspan="9"><div align="center">DEFERIMENTO DA SOLICITAÇÃO</div></td>
            </tr>
			<tr class="exibir">
			<td colspan="9"><div align="center">
			  <table width="100%" border="0">

			    <tr bgcolor="#EEEEEE" class="form">
			      <td width="47%">
		          <div align="center"><strong>
                  <input name="rdbmotivo" type="radio" value="C" onClick="document.form1.confirma.disabled=false;document.form1.frmmotivo.value='CONFIRMAR SOLICITACAO';document.form1.frmdeferimento.value='C'">
                  CONFIRMAR SOLICITAÇÃO</strong></div></td>
			  <td width="53%">
			    <div align="center"><strong><input name="rdbmotivo" type="radio" value="N" onClick="document.form1.confirma.disabled=false;;document.form1.frmmotivo.value='NEGAR SOLICITACAO';document.form1.frmdeferimento.value='N'">
		        NEGAR SOLICITAÇÃO</strong></div></td>
			  </tr>
			    <tr bgcolor="#EEEEEE" class="form">
			      <td colspan="2"><hr></td>
		        </tr>
			    <tr bgcolor="#EEEEEE" class="titulos">
			      <td colspan="2"><div align="center">DEFERIMENTO(especificar) </div></td>
	            </tr>
			    <tr bgcolor="#EEEEEE" class="form">
			      <td colspan="2"><label>
			        <div align="center">
			          <textarea name="frmdescoutros" cols="120" rows="5"></textarea>
		            </div>
			      </label></td>
	            </tr>							  
		      </table>
			  </div></td>
			</tr>
            <tr>
              <td colspan="10">
			  <table width="100%" border="0">
<cfif trim(rsAnexo.PPU_Anexo) neq ''>
		<tr>
        <td colspan="2" bgcolor="eeeeee" class="exibir"><strong class="exibir">ANEXO da Solicitação:</strong></td>
        </tr>
		  <tr>
            <td bgcolor="eeeeee" class="form"><cfoutput>#ListLast(rsAnexo.PPU_Anexo,'\')#</cfoutput>
              <cfset arquivo = ListLast(rsAnexo.PPU_Anexo,'\')></td>
            <td width="16%" align="center" bgcolor="eeeeee"><input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" /></td>
            </tr>
</cfif>
<!--- 		  <tr>
		    <td colspan="2" bgcolor="eeeeee" class="form"><strong>Motivo da Solicitação:</strong></td>
		    </tr>
		  <tr>
		    <td colspan="2" bgcolor="eeeeee" class="form"><cfoutput>#rsPermuta.PPU_Motivo#</cfoutput></td>
		    </tr> --->
		  <tr>
		    <td colspan="2" bgcolor="eeeeee" class="form"><strong>Solicitação:</strong></td>
		    </tr>
		  <tr>
		    <td colspan="2" bgcolor="eeeeee" class="form"><textarea name="frmsolitado" cols="125" rows="15" readonly><cfoutput>#rsPermuta.PPU_Parecer#</cfoutput></textarea></td>
		    </tr>
              </table>			  </td>
            </tr>
            <tr>
              <td colspan="10">&nbsp;</td>
            </tr>
            <tr>
              <td>
			  <div align="center">
	        <input name="cancelar" class="botao" type="button" value="Voltar" onClick="voltar()">
	        </div>			  </td>
              <td colspan="9">
                <div align="center">
                  <button type="submit" class="botao" name="confirma" disabled="disabled" onClick="document.form1.sacao.value = 'alt'">Autorizar Solicitação de Permuta de Unidade </button>
                </div></td>
			</tr>			

            <input name="frmmotivo" type="hidden" id="frmmotivo" value="">
			<input name="frmdeferimento" type="hidden" id="frmdeferimento" value="">
            <input name="sacao" type="hidden" id="sacao" value="">
            <input name="frmse" type="hidden" id="frmse" value="<cfoutput>#form.frmse#</cfoutput>">
            <input name="frmano" type="hidden" id="frmano" value="<cfoutput>#form.frmano#</cfoutput>">
            <input name="frmunidde" type="hidden" id="frmunidde" value="<cfoutput>#form.frmunidde#</cfoutput>">
			<input name="frmuniddedesc" type="hidden" id="frmuniddedesc" value="<cfoutput>#trim(rsPermuta.Und_Descricao)#</cfoutput>">
			<input name="frmunidpara" type="hidden" id="frmunidpara" value="<cfoutput>#form.frmunidpara#</cfoutput>">
			<input name="frmunidparadesc" type="hidden" id="frmunidparadesc" value="<cfoutput>#trim(rsPermuta.unidparadesc)#</cfoutput>">
			<input name="frmpareceratu" type="hidden" id="frmpareceratu" value="<cfoutput>#rsPermuta.PPU_Parecer#</cfoutput>">
			<input name="frmemailretorno" type="hidden" id="frmemailretorno" value="<cfoutput>#rsEmail.Usu_Email#</cfoutput>">
          </form>
	  
<form name="formvolta" method="post" action="Pacin_Permuta_avaliacaob.cfm">
	<input name="frmse" type="hidden" id="frmse" value="<cfoutput>#form.frmse#</cfoutput>">
	<input name="frmano" type="hidden" id="frmano" value="<cfoutput>#form.frmano#</cfoutput>">
	<input name="sacao" type="hidden" id="sacao" value="voltar">
</form> 
          <!--- FIM DA ÁREA DE CONTEÚDO --->
</table>
	
	    <!--- Término da área de conteúdo --->
</body>
</html>

