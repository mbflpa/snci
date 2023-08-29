<cfprocessingdirective pageEncoding ="utf-8"/>  
<cfinclude template="parametros.cfm">
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR, Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="rsChecklistFiltrado" datasource="#dsn_inspecao#">
    SELECT TUI_Modalidade,TUI_TipoUnid,TUI_Ativo, TUI_Ano, TUI_GRUPOITEM, TUI_ITEMVERIF, TUN_Descricao, Grp_Descricao, Itn_Descricao, Itn_Orientacao, Itn_ValorDeclarado, Itn_Amostra, Itn_Norma, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq, Itn_Ano, Itn_PreRelato, Itn_Situacao
    FROM TipoUnidade_ItemVerificacao 
    INNER JOIN Grupos_Verificacao ON Grp_Codigo = TUI_GrupoItem AND Grp_Ano = TUI_Ano 
    INNER JOIN Itens_Verificacao ON (TUI_Modalidade = Itn_Modalidade) and (TUI_TipoUnid = Itn_TipoUnidade) and Itn_NumItem = TUI_ItemVerif AND Itn_NumGrupo = TUI_GrupoItem AND Itn_Ano = TUI_Ano
    INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
    WHERE TUI_Modalidade = '#url.frmmodal#' 
	<cfif ucase(trim(qAcesso.Usu_GrupoAcesso)) eq 'INSPETORES' or #url.frmtpano# eq year(now())>
	and Itn_Situacao = 'A'
	</cfif>
	and Itn_Ano = '#url.frmtpano#' and TUI_TipoUnid = #url.frmtipo#
    ORDER BY TUI_GRUPOITEM, TUI_ITEMVERIF, TUN_Descricao  
</cfquery>
   

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Sistema Nacional de Controle Interno</title>
        <link href="../../../css.css" rel="stylesheet" type="text/css" />
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      
        <style type="text/css">
            html {margin:1cm 1cm;}
        </style>

        <script language="javascript">
            function printpr(OLECMDID){
                var OLECMDID = 7;
                /* OLECMDID values:
                * 6 - print
                * 7 - print preview
                * 8 - page setup (for printing)
                * 1 - open window
                * 4 - Save As
                * 10 - properties
                */
                var PROMPT = 1; // 1 PROMPT & 2 DONT PROMPT USER
                var WebBrowser = '<OBJECT ID="WebBrowser1" WIDTH=30 HEIGHT=22 CLASSID="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"></OBJECT>';
                document.body.insertAdjacentHTML('beforeEnd', WebBrowser);
                WebBrowser1.ExecWB(OLECMDID,PROMPT);
                WebBrowser1.outerHTML = "";
           
            }
        </script>

    
    </head>

    <body id="main_body" style="background:#fff">
<cfif rsChecklistFiltrado.recordcount lte 0> 
	<div class="noprint" align="left" >Checklist desativado para o Ano Corrente ou n&atilde;o foi gerado para o Tipo e o Ano Selecionado</div>
<cfabort>  
</cfif> 
        
        <form id="formPlanoTeste"  name="formPlanoTeste" >
          <div class="noprint" align="left" ><button type="button" onClick="printpr(document.main_body);">Imprimir</button>&nbsp;<input type="button" value="FECHAR" onclick="window.close()";>
          </div>

		  
              <table width="75%" border="0" cellspacing="4" widtd="100%">
                <thead>
                  <tr >
                    <td colspan="8" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center" ><img src="GeraRelatorio/geral/img/logoCorreios.gif" alt="Logo ECT"  width="207" height="56" style="" /></div></td>
                  </tr>
                  <tr >
                    <td colspan="8" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center" style=""><span class="style2" style="color:#053c5e;font-size:14px;"><strong>DEPARTAMENTO DE CONTROLE INTERNO</strong></span></div></td>
                  </tr>
                  <tr>
                    <td colspan="8" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center"> <span class="style2"  style="color:#053c5e;font-size:14px"><strong>PLANO DE TESTES</strong></span></div></td>
                  </tr>
                  <tr>
                    <td width="15%"  valign="top" bordercolor="999999" bgcolor="" scope="row"></td>
                  </tr>
                </thead>
                <tr>
                  <td colspan="8" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"> <span class="style2"  style="color:#053c5e;">Tipo de unidade: <cfoutput><strong>#rsChecklistFiltrado.TUN_Descricao#</strong></cfoutput></span> </div></td>
                </tr>
                <tr>
                  <td colspan="8" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"> <span class="style2"  style="color:#053c5e;">Modalidade: <cfoutput><strong>
                    <cfif #url.frmmodal# eq 0>
                      PRESENCIAL
                        <cfelseif #url.frmmodal# eq 1>
                      A DISTÂNCIA
                      <cfelseif #url.frmmodal# eq '2'>
                      PRESENCIAL e A DISTÂNCIA
                      <cfelse>
                      #rsChecklistFiltrado.TUI_Modalidade#
                    </cfif>
                  </strong></cfoutput></span> </div></td>
                </tr>
                <tr >
                  <td colspan="8" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"> <span class="style2"  style="color:#053c5e">Ano: <cfoutput><strong>#rsChecklistFiltrado.TUI_Ano#</strong></cfoutput></span> </div></td>
                </tr>
                <tr>
                  <td  valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                </tr>
                <cfoutput query="rsChecklistFiltrado" group="TUI_GRUPOITEM">
                  <tr>
                    <td colspan="10" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="justify" style="background:F5F5F5;color:##053c5e;"><strong>GRUPO: #TUI_GRUPOITEM# #Grp_Descricao#</strong></div></td>
                  </tr>
                  <cfoutput> 
                    <tr>
					<td colspan="10" valign="top" bordercolor="999999" bgcolor="" scope="row">
					<div style="text-align: justify;"><strong>
<!---                       <cfif '#url.frmacao#' eq 'S'> --->
                        Item: #TUI_GRUPOITEM#.#TUI_ITEMVERIF#  #Itn_Descricao#
<!---                       <cfelse>
                        Item: #TUI_GRUPOITEM#.#TUI_ITEMVERIF# - #Itn_Descricao#
                      </cfif> --->
					  </strong></div>					   </td>
                    </tr>
					<cfif Itn_Situacao eq 'A'>
						<cfset auxsitudesc = 'ATIVA'>
					<cfelse>
						<cfset auxsitudesc = 'DESATIVADA'>
					</cfif>
					<cfif ucase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER'>					
                    <tr>
                      <td><strong>Relev&acirc;ncia:</strong></td>
                      <td width="18%"><div align="right"><strong>Pontua&ccedil;&atilde;o:</strong></div></td>
                      <td width="14%"><div align="left"><strong>#Itn_Pontuacao#</strong></div></td>
                      <td width="11%"><div align="right"><strong>Classifica&ccedil;&atilde;o:</strong></div></td>
                      <td width="15%"><strong>&nbsp;#Itn_Classificacao#</strong></td>
					<cfif ucase(trim(qAcesso.Usu_GrupoAcesso)) neq 'INSPETORES'>					  
                      <td width="16%"><div align="right"><strong>Situa&ccedil;&atilde;o do Ponto:</strong></div></td>
                      <td width="11%"><div align="left"><strong>#auxsitudesc#</strong></div></td>
					</cfif>					  
                    </tr>
					</cfif>
				
			<cfif '#url.frmacao#' eq 'S'>
					<cfif ucase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER'>
                      <tr>
                        <td colspan="10"><div align="left"><strong>Composi&ccedil;&atilde;o da Pontua&ccedil;&atilde;o</strong></div></td>
                      </tr>
                      <cfset itnptcseq = trim(Itn_PTC_Seq)>
                      <cfif len(itnptcseq) lte 0>
                        <cfset itnptcseq = 0>
                      </cfif>
                      <cfquery name="rsComp" datasource="#dsn_inspecao#">
                        SELECT PTC_Seq, PTC_Valor, PTC_Descricao
                        FROM Pontuacao
                        WHERE PTC_Ano=#Itn_Ano# and PTC_Seq In (#itnptcseq#)
                      </cfquery>
                      <tr>
                        <td><div align="center"><strong>ID</strong></div></td>
                        <td><div align="center"><strong>Peso</strong></div></td>
                        <td colspan="5" ><strong>Descri&ccedil;&atilde;o</strong></td>
                      </tr>
                      <cfloop query="rsComp">
                        <tr>
                          <td><div align="center">#rsComp.PTC_Seq#</div></td>
                          <td><div align="center">#rsComp.PTC_Valor#</div></td>
                          <td colspan="5" >#rsComp.PTC_Descricao#</td>
                        </tr>
                      </cfloop>
					  
					  
                      <cfset ItnPreRelato = Replace(Itn_PreRelato,"
                      ","<BR>" ,"All")>
                      <cfset ItnPreRelato = Replace(ItnPreRelato,"-----------------------------------------------------------------------------------------------------------------------","<BR>-----------------------------------------------------------------------------------------------------------------------<BR>" ,"All")>
                      <tr>
                        <td colspan="7"><div align="left"><strong>Pr&eacute;-Relato</strong></div></td>
                      </tr>
                      <tr>
                        <td colspan="7">#ItnPreRelato#</td>
                      </tr>
					</cfif>					  
                      <tr>
                        <td  valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                      </tr>
                      <tr>
                        <td colspan="10" valign="top" bordercolor="999999" bgcolor="" scope="row"><div style="text-align: justify;"><strong><u><i>Como Verificar / Procedimentos Adotados: </i></u></strong>#Itn_Orientacao#</div></td>
                      </tr>
                      <tr>
                        <td  valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                      </tr>
                      <tr>
                        <td colspan="10" valign="top" bordercolor="999999" bgcolor="" scope="row"><div style="text-align: justify;"><strong><u><i>Amostra: </i></u></strong>#Itn_Amostra#</div></td>
                      </tr>
                      <tr>
                        <td colspan="10" valign="top" bordercolor="999999" bgcolor="" scope="row"><div style="text-align: justify;"><strong><u><i>Norma: </i></u></strong>#Itn_Norma#</div></td>
                      </tr>
                    </cfif>
					
                    <tr>
                      <td  valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                    </tr>
                 </cfoutput> 
                  <tr>
                    <td  colspan="12" valign="top" bordercolor="999999" bgcolor=""  scope="row">&nbsp;</td>
                  </tr>
                </cfoutput>
                <tr>
                  <!---<tfoot>
                    <tr><td><div class="noprint" align="CENTER"><button type="button" onClick="window.print();">Imprimir</button></div></td></tr>
                    <tr><td><div class="divFooter" align="right" style="position:relative;left:0px;font-size:12px;float:left">SNCI - Sistema Nacional de Controle Interno</div>
                    <div class="divFooter" align="right" style="position:relative;right:0px;font-size:12px">Data/Hora de Emissão:<cfoutput>#DateFormat(Now(),"DD/MM/YYYY")#</cfoutput> - <cfoutput>#TimeFormat(Now(),'HH:MM')#</cfoutput></div></td></tr>
                </tfoot>--->
                </tr>
              </table>
            </div>
    </form>
        <footer>
            <div class="noprint" align="CENTER"><button type="button" onClick="window.print();">Imprimir</button></div>
        </footer>
    </body>
    

    </html>
