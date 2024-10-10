<cfprocessingdirective pageEncoding ="utf-8">  
<cfset grp = ''>
<cfset itm = ''>
<cfloop list="#form.grpitem#" index="vlr">
  <cfif grp eq ''>
    <cfset grp = vlr>
  <cfelse>
    <cfset itm = vlr>
  </cfif>
</cfloop>    
<cfoutput>
    <cfquery name="qAcesso" datasource="#dsn_inspecao#">
        select Usu_Matricula,Usu_GrupoAcesso 
        from usuarios 
        where Usu_login = '#cgi.REMOTE_USER#'
    </cfquery>
    <cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>
     
    <cfquery datasource="#dsn_inspecao#" name="rsFicha">
        SELECT Diretoria.Dir_Sigla as siglainsp, INP_NumInspecao, INP_Unidade, INP_DtInicInspecao, INP_DtFimInspecao, INP_DTConcluirAvaliacao, INP_DTConcluirRevisao, 
        INP_Coordenador, Fun_Nome, Fun_Matric, IPT_MatricInspetor, 
        Usuarios.Usu_LotacaoNome, Usuarios_1.Usu_Apelido as nomerevisor, Usuarios_1.Usu_LotacaoNome as lotacaorevisor, 
        Usuarios_1.Usu_Matricula as matrrevisor, Und_Descricao, Diretoria_1.Dir_Sigla, Diretoria_2.Dir_Sigla as siglaunid
        FROM (((((((Inspecao INNER JOIN 
        Inspetor_Inspecao ON (INP_NumInspecao = IPT_NumInspecao) AND (INP_Unidade = IPT_CodUnidade)) 
        INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
        INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric) 
        INNER JOIN Usuarios ON Fun_Matric = Usuarios.Usu_Matricula) 
        INNER JOIN Usuarios AS Usuarios_1 ON INP_UserName = Usuarios_1.Usu_Login) 
        INNER JOIN Diretoria AS Diretoria_1 ON Usuarios_1.Usu_DR = Diretoria_1.Dir_Codigo) 
        INNER JOIN Diretoria ON Fun_DR = Diretoria.Dir_Codigo) 
        INNER JOIN Diretoria AS Diretoria_2 ON Und_CodDiretoria = Diretoria_2.Dir_Codigo
        WHERE INP_NumInspecao = convert(varchar,'#form.numinsp#') and INP_Situacao = 'CO'
    </cfquery>

    <cfquery datasource="#dsn_inspecao#" name="rsItem">
        SELECT RIP_Resposta, Itn_NumGrupo, Itn_NumItem, Itn_Descricao, Grp_Descricao, RIP_MatricAvaliador, Fun_Nome, Fun_Email, FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, 
		FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos, 
		FACA_Consideracao_Revisor, FACA_Consideracao_Avaliador, FACA_Consideracao_SCOI, FACA_Consideracao_SGCIN, FACA_Avaliacao
        FROM Unidades 
        INNER JOIN ((Inspecao 
        INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) 
        INNER JOIN Itens_Verificacao ON (INP_Modalidade = Itn_Modalidade) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo)) ON (Und_TipoUnidade = Itn_TipoUnidade) AND (Und_Codigo = RIP_Unidade)
        INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)
        INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
        left JOIN UN_Ficha_Facin_Avaliador ON (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade) AND (RIP_MatricAvaliador = FACA_Avaliador) AND (Itn_NumGrupo = FACA_Grupo) AND (Itn_NumItem = FACA_Item)
        WHERE convert(char, RIP_Ano) = Itn_Ano AND INP_NumInspecao = convert(varchar,'#form.numinsp#') and INP_Situacao = 'CO' 
        AND RIP_Resposta = 'N' and Itn_NumGrupo=#grp#  and Itn_NumItem = #itm#
        <cfif grpacesso eq 'INSPETORES'>
            AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
        </cfif>
    </cfquery>
   <cfquery datasource="#dsn_inspecao#" name="rsRIP">
        SELECT RIP_NumInspecao, Count(RIP_NumInspecao) AS TotalRIP
        FROM Resultado_Inspecao
        GROUP BY RIP_NumInspecao
        HAVING RIP_NumInspecao=convert(varchar,'#form.numinsp#')
    </cfquery>
    
    <cfquery datasource="#dsn_inspecao#" name="rsAvalia">
        SELECT RIP_MatricAvaliador, Fun_Nome, Count(RIP_MatricAvaliador) AS totaval
        FROM Resultado_Inspecao 
        INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
        GROUP BY RIP_NumInspecao, RIP_MatricAvaliador, Fun_Nome, RIP_Resposta
        HAVING RIP_NumInspecao = convert(varchar,'#form.numinsp#') AND RIP_Resposta = 'N'
        <cfif grpacesso eq 'INSPETORES'>
            AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
        </cfif>
    </cfquery>

    <cfquery datasource="#dsn_inspecao#" name="rsDevol">
        SELECT RIP_NumInspecao, Count(RIP_NumInspecao) AS totdevol
        FROM Resultado_Inspecao
        WHERE RIP_Recomendacao_Inspetor Is Not Null
        GROUP BY RIP_NumInspecao
        HAVING RIP_NumInspecao = convert(varchar,'#form.numinsp#')
    </cfquery>

    <cfquery datasource="#dsn_inspecao#" name="rsExisteFacin">
        SELECT FAC_Qtd_Geral, FAC_Qtd_NC, FAC_Qtd_Devolvido, 
        FAC_Pontos_Revisao_Meta1, FAC_Perc_Revisao_Meta1, FAC_Meta1_Peso_Item, FAC_Pontos_Revisao_Meta2, FAC_Perc_Revisao_Meta2, FAC_Meta2_Peso_Item, FAC_Data_Plan_Meta3, 
        FAC_DifDia_Meta3, FAC_Perc_Meta3, FAC_DtAlter
        FROM UN_Ficha_Facin
        WHERE FAC_Avaliacao = convert(varchar,'#form.numinsp#') and FAC_Matricula = #qAcesso.Usu_Matricula#
    </cfquery>

    <cfif rsExisteFacin.recordcount lte 0>
        <cfset form.ptogeral = #rsRIP.TotalRIP#>
        <cfset form.meta1 = 100>
        <cfset form.meta2 = 100>
        <cfset form.ptorevismeta1 = #rsRIP.TotalRIP#>
        <cfset form.ptorevismeta2 = #rsRIP.TotalRIP#>
    <cfelse>
        <cfset form.ptogeral = #rsExisteFacin.FAC_Qtd_Geral#>
        <cfset form.ptodev = #rsExisteFacin.FAC_Qtd_Devolvido#>
        <cfset form.meta1 = #rsExisteFacin.FAC_Perc_Revisao_Meta1#>
        <cfset form.meta2 = #rsExisteFacin.FAC_Perc_Revisao_Meta2#>
        <cfset form.ptorevismeta1 = #rsExisteFacin.FAC_Pontos_Revisao_Meta1#>
        <cfset form.ptorevismeta2 = #rsExisteFacin.FAC_Pontos_Revisao_Meta2#>
    </cfif>
    <cfset ptogrpitm = numberFormat((100/form.ptogeral),'___.0')>

<!DOCTYPE html>
<html lang="pt-BR">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FICHA AVALIAÇÃO</title>
    <link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">
     <link rel="stylesheet" href="public/app.css">  

    <script>

            function colecao_meta1(a){
           // alert(a);
            var matric_inspetor = a;
            var matric_colecao;
            var vlx = 0;
            var ptobtidaitem = document.facin.ptobtida.value;
            const myCollection = document.getElementsByTagName("input");
            for (let i = 0; i < myCollection.length; i++) 
                {
                   // myCollection[i].style.color = "red";
                    matric_colecao = myCollection[i].name;
                    id_colecao = myCollection[i].id;
                    matric_colecao = matric_colecao.substring(16,matric_colecao.length);
                    id_colecao = id_colecao.substring(0,5);
                    if (matric_inspetor == matric_colecao && id_colecao == 'meta1') {
                   //     alert('Nome: ' + myCollection[i].name + ' valor: ' + myCollection[i].value + ' nomeid ' + id_colecao);
                        vlx = vlx + eval(myCollection[i].value);
                    }
                }
            var totavalinspetor = document.getElementById("meta1_qggitens_" + a).innerHTML;
            var percmeta1 = parseFloat((vlx / (totavalinspetor * ptobtidaitem))*100).toFixed(2);
            document.getElementById("meta1_qgpto_" + a).innerHTML = (vlx).toFixed(2);
            document.getElementById("meta1_percqggitens_" + a).innerHTML=percmeta1 + ' %';    
            ajustar(1,a,vlx,percmeta1);     
        }
        //============================================================================
        function colecao_meta2(a){
            //alert(a);
            var matric_inspetor = a;
            var matric_colecao;
            var vlx =0;
            var ptobtidaitem = document.facin.ptobtida.value;
            const myCollection = document.getElementsByTagName("input");
            for (let i = 0; i < myCollection.length; i++) 
                {
                   // myCollection[i].style.color = "red";
                    matric_colecao = myCollection[i].name;
                    id_colecao = myCollection[i].id;
                    matric_colecao = matric_colecao.substring(16,matric_colecao.length);
                    id_colecao = id_colecao.substring(0,5);
                    if (matric_inspetor == matric_colecao && id_colecao == 'meta2') {
              //     alert('Nome: ' + myCollection[i].name + ' valor: ' + myCollection[i].value + ' nomeid ' + id_colecao);
                        vlx = vlx + eval(myCollection[i].value);
                    }
                }
            var totavalinspetor = document.getElementById("meta2_qggitens_" + a).innerHTML;
            var percmeta2 = parseFloat((vlx / (totavalinspetor * ptobtidaitem))*100).toFixed(2);
            document.getElementById("meta2_qgpto_" + a).innerHTML = (vlx).toFixed(2);
            document.getElementById("meta2_percqggitens_" + a).innerHTML=percmeta2 + ' %';      
            ajustar(2,a,vlx,percmeta2);                       
        }
        //============================================================================
        function meta1(a,b,c,d,e,f){
            atualizarponto(a,e,f);
          //  alert(a + ' ' +  b  + ' ' + c  + ' ' + d + ' ' + e + '  ' + f);
            var meta1desc = document.facin.meta1desconto.value;
            var ptobtidaitem = document.facin.ptobtida.value;
            var vlritem = c;
            var tot = 0;
            var vlx = 0;
            var vlrptogeral = eval(document.getElementById("ptogeral").innerHTML);
            var totNC =   document.facin.totalNC.value;
            var descptogeral = (ptobtidaitem * totNC);
            if (a){
                 vlritem = parseFloat(vlritem - meta1desc).toFixed(1);
            } else {
                 vlritem =  parseFloat((vlritem * 10) + (meta1desc * 10));
                 vlritem = (vlritem / 10);
            }
          //  alert(vlritem);
            document.getElementById("meta1_pto" + b).value = vlritem;
            document.getElementById("facameta1pontos_" + e).value = vlritem;

            for (let i = 1; i <= totNC; i++) {
                vlx = eval(document.getElementById("meta1_pto" + i).value);
                tot = tot + vlx;
            } 
           // alert(descptogeral + '  ' + tot);
            if (descptogeral == tot) {
                descptogeral = 0;
            }else{
                descptogeral = (descptogeral - tot);
            }
            var pormeta1 = (vlrptogeral - descptogeral).toFixed(2);
            document.getElementById("ptorevismeta1").innerHTML = pormeta1;
            document.formx.facpontosrevisaometa1.value = pormeta1;
            var percmeta1 = parseFloat((pormeta1/vlrptogeral)*100).toFixed(2);
            document.getElementById("meta1").innerHTML = percmeta1 + ' %';
            document.formx.facpercrevisaometa1.value = percmeta1;
        } 
        //===========
        function meta2(a,b,c,d,e,f){
          //  alert(a + ' ' +  b  + ' ' + c  + ' ' + d);
            atualizarponto(a,e,f);
            var meta2desc = document.facin.meta2desconto.value;
            var ptobtidaitem = document.facin.ptobtida.value;
            var vlritem = c;
            var tot = 0;
            var vlx = 0;
            var vlrptogeral = eval(document.getElementById("ptogeral").innerHTML);
            var totNC = document.facin.totalNC.value;
            var descptogeral = (ptobtidaitem * totNC);
            if (a){
                 vlritem = parseFloat(vlritem - meta2desc).toFixed(1);
            } else {
                 vlritem =  parseFloat((vlritem * 10) + (meta2desc * 10));
                 vlritem = (vlritem / 10);
            }
            document.getElementById("meta2_pto" + b).value = vlritem;
            document.getElementById("facameta2pontos_" + e).value = vlritem;

            for (let i = 1; i <= totNC; i++) {
                vlx = eval(document.getElementById("meta2_pto" + i).value);
                tot = tot + vlx;
            }  
            if (descptogeral == tot) {
                descptogeral = 0;
            }else{
                descptogeral = (descptogeral - tot);
            }
            var pormeta2 = (vlrptogeral - descptogeral).toFixed(2);
            document.getElementById("ptorevismeta2").innerHTML = (pormeta2);
            document.formx.facpontosrevisaometa2.value = pormeta2;
            var percmeta2 = parseFloat((pormeta2/vlrptogeral)*100).toFixed(2);
            document.getElementById("meta2").innerHTML = percmeta2 + ' %';
            document.formx.facpercrevisaometa2.value = percmeta2;
        }
        //===========  
        const second = 1000;
        const minute = second * 60;
        const hour = minute * 60;
        const day = hour * 24;

        function meta3(a,b){
          //  alert(document.facin.concaval.value);
          if (a.length == 10){
            let date_ini = new Date(a);
            let date_end = new Date(b);
            var percent;
            //alert(date_ini + '   ' + date_end);
            let diff = date_end.getTime() - date_ini.getTime();
            
            diff = Math.floor(diff / day);
           // alert(diff);
           if(diff < 0){
                diff = 0;
                document.facin.meta3_dtplanej.value = a;
            }
            if(diff >= 4) {percent = 0;}
            if(diff == 3) {percent = 30;}
            if(diff == 2) {percent = 50;}
            if(diff == 1) {percent = 70;}
            if(diff <= 0) {percent = 100;}
            document.getElementById('meta3_dif').innerText = diff;
            document.getElementById('meta3_percent').innerText = percent + '%';
            document.formx.facdataplanmeta3.value = b;
            document.formx.facdifdiameta3.value = diff;
            document.formx.facpercmeta3.value = percent;
            
            
            }
        
        }        
        //===========
        function numericos(){
            var tecla = window.event.keyCode;
            if ((tecla != 46) && ((tecla < 48) || (tecla > 57))){
                event.returnValue = false; 
            }
        }
        //================ 
        function Mascara_Data(data){
	        switch (data.value.length)
	        {
                case 2:
                if (data.value < 1 || data.value > 31) {
                    //alert('Valor para o dia inválido!');
                    data.value = '';
                    event.returnValue = false;
                    break;
                    } else {
                    data.value += "/";
                        break;
                    }
                case 5:
                if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
               // alert('Valor para o Mês inválido!');
                data.value = '';
                event.returnValue = false;
                break;
                } else {
                data.value += "/";
                    break;
                }
	        }
        }	
  
</script>

</head>

<!--- <body onload="meta2(true,1,1,85051071);colecao_meta2(85051071)"> --->
<body onload="">
<form name="facin" method="POST" action="">
        
<br>
<div class="container">
	<div class="row align-items-center">
        <span class="border border-primary">
            <p class="text-center"><strong>(FACIN) - FICHA DE AVALIAÇÃO DE CONTROLE INTERNO ANO 2024 - SGCIN/PE</strong></p>
        </span>  
                
        <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>01-Identificação</strong></label>
        <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Inspetores</strong></label>
    

        <div class="col-sm-5">
            <cfloop query="rsFicha">
                <p class="text-start">
                <cfif trim(rsFicha.INP_Coordenador) eq trim(rsFicha.IPT_MatricInspetor)>
                    <label for="" class="">&nbsp;#rsFicha.Fun_Nome# <strong>(coordenador(a))</strong></label>
                <cfelse>  
                    <label for="" class="">&nbsp;#rsFicha.Fun_Nome#</label>              
                </cfif>
                </p>            
            </cfloop>    
        </div>
        <div class="col-sm-2">
            <cfloop query="rsFicha">
                <p>&nbsp;#rsFicha.IPT_MatricInspetor#</p>
            </cfloop>  
        </div>
        <div class="col-sm-5">
            <cfloop query="rsFicha">
            <p>
                #rsFicha.Usu_LotacaoNome#(SE-#rsFicha.siglainsp#)    
            </p>           
            </cfloop>  
        </div>


    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Revisor(a)</strong></label>

        <div class="col-sm-5">
            #rsFicha.nomerevisor#        
        </div>
        <div class="col-sm-1">
            #rsFicha.matrrevisor#                 
        </div>
        <div class="col-sm-6">
                #rsFicha.lotacaorevisor#(SE-#rsFicha.Dir_Sigla#)              
        </div>

    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>02.Processo Avaliado</strong></label>

        <div class="col-sm-6">
            Unidade: #rsFicha.Und_Descricao#(SE/#rsFicha.siglaunid#)
        </div>
        <div class="col-sm-6">
            Nº Avaliação: #rsFicha.INP_NumInspecao#                
        </div>

    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>03.Período das fases da Avaliação de Controle Interno</strong></label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;Execução em campo</label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;Conclusão Avaliação</label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;Conclusão Revisão</label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;Arquive-se SEI</label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;Início: #dateformat(rsFicha.INP_DtInicInspecao,"DD/MM/YYYY")# Fim: #dateformat(rsFicha.INP_DtFimInspecao,"DD/MM/YYYY")#</label>
    <label id="concluiraval" for="" class="col-sm-3 col-form-label">#dateformat(rsFicha.INP_DTConcluirAvaliacao,"DD/MM/YYYY")#</label>
    <input type="hidden" name="concaval" value="#dateformat(rsFicha.INP_DTConcluirAvaliacao,"YYYY-MM-DD")#">
    <label for="" class="col-sm-3 col-form-label">&nbsp;#dateformat(rsFicha.INP_DTConcluirRevisao,"DD/MM/YYYY")#</label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;#dateformat(rsFicha.INP_DTConcluirAvaliacao,"DD/MM/YYYY")#</label>
    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>04.Avaliação</strong></label>
    <label for="" class="col-sm-4 col-form-label">&nbsp;Qtd. Geral de Pontos &nbsp;<div id="ptogeral" class="badge bg-primary text-wrap" style="width: 4rem;">#form.ptogeral#</div></label>
    <!--- <cfif rsExisteFacin.recordcount lte 0> --->
        <cfset form.ptodev = 0>
        <cfset auxpercptodev = 0>
        <cfif rsDevol.totdevol gt 0>
            <cfset form.ptodev = rsDevol.totdevol>
            <cfset auxpercptodev = (form.ptodev / form.ptogeral)>
            <cfset auxpercptodev = numberFormat(auxpercptodev,'___.00')>
        </cfif>
    <!--- </cfif>     --->
    <label for="" class="col-sm-4 col-form-label">&nbsp;Qtd. Pontos Devolvidos &nbsp;<div id="ptodev" class="badge bg-primary text-wrap" style="width: 3rem;">#form.ptodev#</div></label>
    <label for="" class="col-sm-4 col-form-label">&nbsp;Percentual de Devolução&nbsp;<div id="perdev" class="badge bg-primary text-wrap" style="width: 5rem;"><cfoutput>#auxpercptodev#</cfoutput>%</div></label>

  
    <label for="" class="col-sm-6 col-form-label">&nbsp;Pontos Obtidos na Revisão Geral (Meta1) <div id="meta1" class="badge bg-primary text-wrap" style="width: 5rem;">#form.meta1#%</div></label>
    <label for="" class="col-sm-6 col-form-label">&nbsp;Pontos Obtidos na Revisão Geral (Meta2) <div id="meta2" class="badge bg-primary text-wrap" style="width: 5rem;">#form.meta2#%</div></label>
    <label for="" class="col-sm-6 col-form-label"><div id="ptorevismeta1" class="badge bg-primary text-wrap" style="width: 5rem;"><cfoutput>#form.ptorevismeta1#</cfoutput></div></label>
    <label for="" class="col-sm-6 col-form-label"><div id="ptorevismeta2" class="badge bg-primary text-wrap" style="width: 5rem;"><cfoutput>#form.ptorevismeta2#</cfoutput></div></label>
    <p class="text-center"><strong>METAS</strong></p>
</cfoutput>

<div class="accordion" id="acordiongrupoitem">
  <cfset ordem = 0>
  <cfloop query="rsItem">
    <cfset ordem = ordem + 1>
    <cfset linha = 'A_' & rsItem.Itn_NumGrupo & '_' & rsItem.Itn_NumItem>
    <cfset grpitm = rsItem.Itn_NumGrupo & '_' & rsItem.Itn_NumItem>
    
  <div class="accordion-item">
    <h2 class="accordion-header" id="headingOne">
      <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#<cfoutput>#linha#</cfoutput>" aria-expanded="true" aria-controls="<cfoutput>#linha#</cfoutput>">
        <cfoutput>
            #grpitm# - #rsItem.Grp_Descricao# &nbsp;&nbsp;Avaliador(a) : #rsItem.RIP_MatricAvaliador# - #rsItem.Fun_Nome# - #rsItem.Fun_Email# 
        </cfoutput>
      </button>
    </h2>
    <div id="<cfoutput>#linha#</cfoutput>" class="accordion-collapse collapse" aria-labelledby="headingOne" data-bs-parent="#acordiongrupoitem">
      <div class="accordion-body">
        <cfoutput>#rsItem.Itn_Descricao#</cfoutput>
      </div>

      <table class="table">
        <tbody>
            <!--- Aspectos Textuais --->
            <tr>
                <td align="center">
                    <strong>Meta 1: Redigir Apontamentos no SNCI</strong>
                </td>
            </tr>
            <cfset form.meta1_pto = #ptogrpitm#>
            <cfif rsItem.FACA_Avaliacao neq ''><cfset form.meta1_pto = #rsItem.FACA_Meta1_Pontos#></cfif>            
            <tr>
                <tr>
                    <td>Pontuação Obtida por Avaliador/Grupo_Item</td>
                    <td>
                        <div class="badge bg-primary text-wrap" style="width: 5rem;"><input class="form-control" type="text" id="meta1_pto<cfoutput>#ordem#</cfoutput>" name="meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>" value="<cfoutput>#form.meta1_pto#</cfoutput>" readonly></div>
                    </td>
                </tr>
            </tr>
            <tr>
                <td align="center">
                    <strong>Aspectos Textuais</strong>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta1_AT_OrtoGram neq 1><cfset auxchck = ''></cfif>   
            <tr>
                <td>Ortografia e Gramática</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_atorgr_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta1(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta1(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta1_AT_CCCP neq 1><cfset auxchck = ''></cfif>              
            <tr>
                <td>Clareza/Concisão e/ou Coerência/Precisão</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_atcccp_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta1(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta1(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <!--- Redigir apontamentos no SNCI --->
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta1_AE_Tecn neq 1><cfset auxchck = ''></cfif>   
            <tr>
                <td align="Center"><strong>Aspectos Estruturais</strong></td>
            </tr>
            <tr>
                <td>Técnica</td>
                <td>
                    <div class="form-check form-switch">
                         <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aetecn_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta1(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta1(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)"> 
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta1_AE_Prob neq 1><cfset auxchck = ''></cfif>              
            <tr>
                <td>Problema</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aeprob_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta1(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta1(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta1_AE_Valor neq 1><cfset auxchck = ''></cfif>                 
            <tr>
                <td>Valor</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aevalo_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta1(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta1(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta1_AE_Cosq neq 1><cfset auxchck = ''></cfif>              
            <tr>
                <td>Consequências</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aecsqc_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta1(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta1(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta1_AE_Norma neq 1><cfset auxchck = ''></cfif>              
            <tr>
                <td>Normativo</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aenorm_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta1(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta1(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta1_AE_Docu neq 1><cfset auxchck = ''></cfif>                
            <tr>
                <td>Documentos</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aedocm_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta1(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta1(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta1_AE_Class neq 1><cfset auxchck = ''></cfif>                
            <tr>
                <td>Classificação</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aeclas_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta1(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta1(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta1_AE_Orient neq 1><cfset auxchck = ''></cfif>               
            <tr>
                <td>Orientação</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_orient_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta1(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta1_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta1(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <!--- FIM Redigir apontamentos no SNCI ---> 
            <!--- Meta 2: Organizar documentos no SEI --->
            <tr>
                <td align="center">
                    <strong>Meta 2: Organizar Documentos no SEI</strong>
                </td>
            </tr>
            <cfset form.meta2_pto = #ptogrpitm#>
            <cfif rsItem.FACA_Avaliacao neq ''><cfset form.meta2_pto = #rsItem.FACA_Meta2_Pontos#></cfif>                
            <tr>
                <td>Pontuação Obtida por Avaliador/Grupo_Item </td>
                <td>
                    <div class="badge bg-primary text-wrap" style="width: 5rem;"><input class="form-control" type="text" id="meta2_pto<cfoutput>#ordem#</cfoutput>" name="meta2_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>" value="<cfoutput>#form.meta2_pto#</cfoutput>" readonly></div>
                </td>
            </tr> 
            <tr>
                <td align="center">
                    <strong>Arquivo</strong>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta2_AR_Falta neq 1><cfset auxchck = ''></cfif>  
            <tr>
                <td>Falta</td>
                <td>
                    <div class="form-check form-switch">                                                                                                                                                                             
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta2_arfalt_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta2(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta2_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta2(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta2_AR_Troca neq 1><cfset auxchck = ''></cfif>             
            <tr>
                <td>Troca</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta2_artroc_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta2(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta2_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta2(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta2_AR_Nomen neq 1><cfset auxchck = ''></cfif>               
            <tr>
                <td>Nomenclatura</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta2_arnomc_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta2(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta2_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta2(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta2_AR_Ordem neq 1><cfset auxchck = ''></cfif>                
            <tr>
                <td>Ordem</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta2_arorde_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta2(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta2_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta2(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>
            <cfset auxchck = 'checked'>
            <cfif rsItem.FACA_Meta2_AR_Prazo neq 1><cfset auxchck = ''></cfif>                  
            <tr>
                <td>Prazo</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta2_arpraz_<cfoutput>#grpitm#</cfoutput>" value="0" onclick="meta2(this.checked,'<cfoutput>#ordem#</cfoutput>',document.facin.meta2_pto_<cfoutput>#grpitm#_#rsItem.RIP_MatricAvaliador#</cfoutput>.value,<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>,'<cfoutput>#grpitm#</cfoutput>',this.id)" onmouseleave="colecao_meta2(<cfoutput>#rsItem.RIP_MatricAvaliador#</cfoutput>)">
                    </div>
                </td>
            </tr>     
            <!--- FIM Meta 2: Organizar documentos no SEI --->
        </tbody>
      </table>
      <cfset inspetorhd =''>
      <cfset outroshd =''>
      <cfif grpacesso eq 'INSPETORES'>
        <cfset inspetorhd ='readonly'>
      <cfelse>
        <cfset outroshd ='readonly'>        
      </cfif>
      <cfset form.arearevisor = ''>
      <cfset form.areainspetor = ''>
      <cfset form.areaiscoi = ''>
      <cfset form.areaisgcin = ''>
      <cfif rsItem.FACA_Avaliacao neq ''>
        <cfset form.arearevisor = trim(rsItem.FACA_Consideracao_Revisor)>
        <cfset form.areainspetor = trim(rsItem.FACA_Consideracao_Avaliador)>
        <cfset form.areaiscoi = trim(rsItem.FACA_Consideracao_SCOI)>
        <cfset form.areaisgcin = trim(rsItem.FACA_Consideracao_SGCIN)>
      </cfif>     
      <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>05-Considerações do Revisor</strong></label>
      <textarea  name="arearevisor_<cfoutput>#grpitm#</cfoutput>" id="arearevisor_<cfoutput>#grpitm#</cfoutput>" class="form-control" placeholder="Considerações para o ponto" <cfoutput>#inspetorhd#</cfoutput> onblur="considerarrevisor('<cfoutput>#grpitm#</cfoutput>',this.value)"><cfoutput>#form.arearevisor#</cfoutput></textarea>	
      <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>06-Considerações Inspetor(a)</strong></label>
      <textarea  name="areainspetor_<cfoutput>#grpitm#</cfoutput>" id="areainspetor_<cfoutput>#grpitm#</cfoutput>" class="form-control" placeholder="Considerações para o ponto" <cfoutput>#outroshd#</cfoutput> onblur="considerarinspetor('<cfoutput>#grpitm#</cfoutput>',this.value)"><cfoutput>#form.areainspetor#</cfoutput></textarea>
      <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>07-Considerações do SCOI- Chefe Imediato</strong></label>
      <textarea  name="areascoi_<cfoutput>#grpitm#</cfoutput>" id="areaiscoi_<cfoutput>#grpitm#</cfoutput>" class="form-control" placeholder="Considerações para o ponto" <cfoutput>#inspetorhd#</cfoutput> onblur="considerarscoi('<cfoutput>#grpitm#</cfoutput>',this.value)"><cfoutput>#form.areaiscoi#</cfoutput></textarea>
      <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>08-Considerações do SGCIN (Em caso de necessidade)</strong></label>
      <textarea  name="areasgcin_<cfoutput>#grpitm#</cfoutput>" id="areaisgcin_<cfoutput>#grpitm#</cfoutput>" class="form-control" placeholder="Considerações para o ponto" <cfoutput>#inspetorhd#</cfoutput> onblur="considerarsgcin('<cfoutput>#grpitm#</cfoutput>',this.value)"><cfoutput>#form.areaisgcin#</cfoutput></textarea>		
    </div>
</cfloop> 
</div>

</div>
</div> 

<cfoutput>
    <div class="row align-items-center">
    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>09.Individualização do resultado das metas por inspetor (a ser preenchido pela equipe de inspetores):</strong></label>
    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Meta 1</strong> - INSP - Redigir 100% dos apontamentos relativos às Não Conformidades (NC) identificadas, conforme critérios definidos pela SGCIN/PE. (Redigir apontamentos)</label>
    <cfloop query="rsAvalia">
        <cfset matraval = rsAvalia.RIP_MatricAvaliador>
        <cfquery datasource="#dsn_inspecao#" name="rsFacinInd">
            SELECT FFI_Meta1_Qtd_Item, FFI_Meta1_Pontuacao_Inicial, FFI_Meta1_Pontuacao_Obtida, FFI_Meta1_Resultado
            FROM UN_Ficha_Facin_Individual
            WHERE FFI_Avaliacao=convert(varchar,'#form.numinsp#') AND FFI_Avaliador='#rsAvalia.RIP_MatricAvaliador#'
        </cfquery>
        <cfset form.meta1_qggitens = #rsAvalia.totaval#>
        <cfset form.meta1_qgptop = (rsAvalia.totaval * ptogrpitm)>
        <cfset form.meta1_qgpto = (rsAvalia.totaval * ptogrpitm)>
        <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
        <cfset form.meta1_percqggitens = numberFormat(percent,'___.00')>
        
        <cfif rsFacinInd.recordcount gt 0>
            <cfset form.meta1_qggitens = #rsFacinInd.FFI_Meta1_Qtd_Item#>
            <cfset form.meta1_qgptop = #rsFacinInd.FFI_Meta1_Pontuacao_Inicial#>
            <cfset form.meta1_qgpto = #rsFacinInd.FFI_Meta1_Pontuacao_Obtida#>
            <cfset form.meta1_percqggitens = #rsFacinInd.FFI_Meta1_Resultado#>
        </cfif>
        
        <div class="col-sm-4">
            <label for="" class="">&nbsp;#rsAvalia.Fun_Nome#</label>  
        </div>
        <div class="col-sm-8">
            <label>&nbsp;Qtd. Item Avaliado: &nbsp;<div id="meta1_qggitens_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta1_qggitens#</div></label>
            <label>&nbsp;Pontuação Inicial:&nbsp;<div id="meta1_qgptop_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta1_qgptop#</div></label>
            <label>&nbsp;Pontuação Obtida:&nbsp;<div id="meta1_qgpto_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta1_qgpto#</div></label>
            <!---<cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
            <cfset percent = numberFormat(percent,'___.00')> --->
            <label>&nbsp;Resultado: &nbsp;<div id="meta1_percqggitens_#matraval#" class="badge bg-primary text-wrap" style="width: 5rem;">#form.meta1_percqggitens#%</div></label>
        </div>
    </cfloop>  
 
    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Meta 2</strong>- INSP - Organizar 100% dos documentos gerados nas Avaliações de Controles realizadas, providenciado o arquivamento conforme critérios estabelecidos pela SGCIN/PE.  (Organizar documentos no SEI)</label>
    <cfloop query="rsAvalia">
        <cfset matraval = rsAvalia.RIP_MatricAvaliador>
        <cfquery datasource="#dsn_inspecao#" name="rsFacinInd">
            SELECT FFI_Meta2_Qtd_Item, FFI_Meta2_Pontuacao_Inicial, FFI_Meta2_Pontuacao_Obtida, FFI_Meta2_Resultado
            FROM UN_Ficha_Facin_Individual
            WHERE FFI_Avaliacao=convert(varchar,'#form.numinsp#') AND FFI_Avaliador='#rsAvalia.RIP_MatricAvaliador#'
        </cfquery>
        <cfset form.meta2_qggitens = #rsAvalia.totaval#>
        <cfset form.meta2_qgptop = (rsAvalia.totaval * ptogrpitm)>
        <cfset form.meta2_qgpto = (rsAvalia.totaval * ptogrpitm)>
        <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
        <cfset form.meta2_percqggitens = numberFormat(percent,'___.00')>
        
        <cfif rsFacinInd.recordcount gt 0>
            <cfset form.meta2_qggitens = #rsFacinInd.FFI_Meta2_Qtd_Item#>
            <cfset form.meta2_qgptop = #rsFacinInd.FFI_Meta2_Pontuacao_Inicial#>
            <cfset form.meta2_qgpto = #rsFacinInd.FFI_Meta2_Pontuacao_Obtida#>
            <cfset form.meta2_percqggitens = #rsFacinInd.FFI_Meta2_Resultado#>
        </cfif>        
        <div class="col-sm-4">
            <label for="" class="">&nbsp;#rsAvalia.Fun_Nome#</label>         
        </div>
        <div class="col-sm-8">
            <label>&nbsp;Qtd. Item Avaliado: &nbsp;<div id="meta2_qggitens_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta2_qggitens#</div></label>
            <label>&nbsp;Pontuação Inicial:&nbsp;<div id="meta1_qgptop_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta2_qgptop#</div></label>            
            <label>&nbsp;Pontuação Obtida:&nbsp;<div id="meta2_qgpto_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta2_qgpto#</div></label>
            <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
            <cfset percent = numberFormat(percent,'___.00')>
            <label>&nbsp;Resultado: &nbsp;<div id="meta2_percqggitens_#matraval#" class="badge bg-primary text-wrap" style="width: 5rem;">#form.meta2_percqggitens#%</div></label>
        </div>
    </cfloop>  
    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Meta 3</strong> - Liberar 100% das Avaliações de Controle para revisão dentro do prazo estabelecido pela SGCIN/PE. (Liberar para revisão no prazo)</label>
    <label for="" class="col-sm-4 col-form-label">&nbsp;Data Transmissão Planejada:</label>
    <label for="" class="col-sm-4 col-form-label">&nbsp;Diferença(dia)</label>
    <label for="" class="col-sm-4 col-form-label">&nbsp;Percentual</label>
    <cfset form.meta3_dtplanej = ''>
    <cfset form.meta3_dif = 0>
    <cfset form.meta3_percent = 100>
    <cfif rsExisteFacin.recordcount gt 0>
        <cfset form.meta3_dtplanej = #rsExisteFacin.fac_data_plan_meta3#>
        <cfset form.meta3_dif = #int(rsExisteFacin.fac_difdia_meta3)#>
        <cfset form.meta3_percent = #rsExisteFacin.fac_perc_meta3#>
    </cfif>
    <label for="" class="col-sm-4 col-form-label"><input class="form-control" id="meta3_dtplanej" name="meta3_dtplanej" type="date" value="#form.meta3_dtplanej#" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" onblur="meta3(document.facin.concaval.value,this.value)" size="14" maxlength="10" placeholder="DD/MM/AAAA" #inspetorhd#></label>
    <label for="" class="col-sm-4 col-form-label"><div id="meta3_dif" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta3_dif#</div></label>
    <label for="" class="col-sm-4 col-form-label"><div id="meta3_percent" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta3_percent#%</div></label>
    <cfset auxcompl = 'Salvar Facin Grupo Acesso: ' & #grpacesso#>
    <cfif rsExisteFacin.recordcount gt 0>
        <cfset auxcompl = 'Salvar Facin (Grupo Acesso: ' & #grpacesso# & '    últ. atualiz.: ' & dateformat(rsExisteFacin.FAC_DtAlter,"DD/MM/YYYY") & ' ' & timeformat(rsExisteFacin.FAC_DtAlter,"HH:MM:SS") & ')'>
    </cfif>
    
    <input class="btn btn-primary" type="button" onclick="validarform()" value="<cfoutput>#auxcompl#</cfoutput>">
    <input class="btn btn-info" type="button" onClick="window.open('ficha_facin_Ref.cfm?numinsp=#form.numinsp#&acao=buscar','_self')" value="Voltar">
</div> 
<cfset meta1desconto = numberFormat((ptogrpitm/10),'___.0')>
<cfset meta2desconto = numberFormat((ptogrpitm/5),'___.0')>
<input type="hidden" name="meta1desconto" value="#trim(meta1desconto)#">
<input type="hidden" name="meta2desconto" value="#trim(meta2desconto)#">
<input type="hidden" name="totalNC" value="#rsItem.recordcount#">
<input type="hidden" name="ptobtida" value="#ptogrpitm#">
</cfoutput>    

</div>

</form>

<form name="formx" method="POST" action="cfc/fichafacin.cfc?method=salvarPosic" target="_self">
    <cfoutput>
        <input type="hidden" name="facunidade" id="facunidade" value="#rsFicha.INP_Unidade#">
        <input type="hidden" name="facavaliacao" id="facavaliacao" value="#form.numinsp#">
        <input type="hidden" name="facmatricula" id="facmatricula" value="#trim(qAcesso.Usu_Matricula)#">
        <input type="hidden" name="facano" id="facano" value="#right(form.numinsp,4)#">
        <input type="hidden" name="facRevisor" id="facRevisor" value="#trim(rsFicha.matrrevisor)#">
        <input type="hidden" name="facdatasei" id="facdatasei" value="#dateformat(rsFicha.INP_DTConcluirAvaliacao,"YYYY-MM-DD")#">
        <input type="hidden" name="facqtdgeral" id="facqtdgeral" value="#form.ptogeral#">
        <input type="hidden" name="facqtdnc" id="facqtdnc" value="#rsItem.recordcount#">
        <input type="hidden" name="facqtdevolvido" id="facqtdevolvido" value="#form.ptodev#">
        <input type="hidden" name="facpontosrevisaometa1" id="facpontosrevisaometa1" value="#form.meta1#">
        <input type="hidden" name="facpercrevisaometa1" id="facpercrevisaometa1" value="#form.ptorevismeta1#">
        <input type="hidden" name="facpontosrevisaometa2" id="facpontosrevisaometa2" value="#form.meta2#">
        <input type="hidden" name="facpercrevisaometa2" id="facpercrevisaometa2" value="#form.ptorevismeta2#">
        <input type="hidden" name="facdataplanmeta3" id="facdataplanmeta3" value="#form.meta3_dtplanej#">
        <input type="hidden" name="facdifdiameta3" id="facdifdiameta3" value="#form.meta3_dif#">
        <input type="hidden" name="facpercmeta3" id="facpercmeta3" value="#form.meta3_percent#">
        <input type="hidden" name="facmeta1pesoitem" id="facmeta1pesoitem" value="#trim(meta1desconto)#">
        <input type="hidden" name="facmeta2pesoitem" id="facmeta2pesoitem" value="#trim(meta2desconto)#">
    <cfloop query="rsAvalia">
        <cfquery datasource="#dsn_inspecao#" name="rsFacinInd">
            SELECT FFI_Meta1_Qtd_Item, FFI_Meta1_Pontuacao_Inicial, FFI_Meta1_Pontuacao_Obtida, FFI_Meta1_Resultado,FFI_Meta2_Qtd_Item, FFI_Meta2_Pontuacao_Inicial, FFI_Meta2_Pontuacao_Obtida, FFI_Meta2_Resultado
            FROM UN_Ficha_Facin_Individual
            WHERE FFI_Avaliacao=convert(varchar,'#form.numinsp#') AND FFI_Avaliador='#rsAvalia.RIP_MatricAvaliador#'
        </cfquery>
        <!--- meta1 --->
        <cfset form.meta1_qggitens = #rsAvalia.totaval#>
        <cfset form.meta1_qgptop = (rsAvalia.totaval * ptogrpitm)>
        <cfset form.meta1_qgpto = (rsAvalia.totaval * ptogrpitm)>
        <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
        <cfset form.meta1_percqggitens = numberFormat(percent,'___.00')>
        <!--- meta2 --->
        <cfset form.meta2_qggitens = #rsAvalia.totaval#>
        <cfset form.meta2_qgptop = (rsAvalia.totaval * ptogrpitm)>
        <cfset form.meta2_qgpto = (rsAvalia.totaval * ptogrpitm)>
        <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
        <cfset form.meta2_percqggitens = numberFormat(percent,'___.00')>
        
        <cfif rsFacinInd.recordcount gt 0>
            <!--- meta1 --->
            <cfset form.meta1_qggitens = #rsFacinInd.FFI_Meta1_Qtd_Item#>
            <cfset form.meta1_qgptop = #rsFacinInd.FFI_Meta1_Pontuacao_Inicial#>
            <cfset form.meta1_qgpto = #rsFacinInd.FFI_Meta1_Pontuacao_Obtida#>
            <cfset form.meta1_percqggitens = #rsFacinInd.FFI_Meta1_Resultado#>
            <!--- meta2 --->
            <cfset form.meta2_qggitens = #rsFacinInd.FFI_Meta2_Qtd_Item#>
            <cfset form.meta2_qgptop = #rsFacinInd.FFI_Meta2_Pontuacao_Inicial#>
            <cfset form.meta2_qgpto = #rsFacinInd.FFI_Meta2_Pontuacao_Obtida#>
            <cfset form.meta2_percqggitens = #rsFacinInd.FFI_Meta2_Resultado#>
        </cfif>   
<!---   
        <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
        <cfset percent = numberFormat(percent,'___.00')> 
--->
        <!--- meta1 --->
        <input type="hidden" name="ffimeta1qtditem_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta1qtditem_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta1_qggitens#">
        <input type="hidden" name="ffimeta1pontuacaoinicial_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta1pontuacaoinicial_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta1_qgptop#">
        <input type="hidden" name="ffimeta1pontuacaoobtida_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta1pontuacaoobtida_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta1_qgpto#">
        <input type="hidden" name="ffimeta1resultado_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta1resultado_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta1_percqggitens#">
        <!--- meta2 --->
        <input type="hidden" name="ffimeta2qtditem_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta2qtditem_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta2_qggitens#">
        <input type="hidden" name="ffimeta2pontuacaoinicial_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta2pontuacaoinicial_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta2_qgptop#">
        <input type="hidden" name="ffimeta2pontuacaoobtida_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta2pontuacaoobtida_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta2_qgpto#">
        <input type="hidden" name="ffimeta2resultado_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta2resultado_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta2_percqggitens#">
    </cfloop>  
    <cfloop query="rsItem">
        <cfset grpitm = rsItem.Itn_NumGrupo & '_' & rsItem.Itn_NumItem>
        <cfset form.meta1_pto = #ptogrpitm#>
        <cfset form.meta2_pto = #ptogrpitm#>
        <cfif rsItem.FACA_Avaliacao neq ''>
            <cfset form.meta1_pto = #FACA_Meta1_Pontos#>
            <cfset form.meta2_pto = #FACA_Meta2_Pontos#>
        </cfif>    
        <input type="hidden" name="facaavaliador_#grpitm#" id="facaavaliador_#grpitm#" value="#rsItem.RIP_MatricAvaliador#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta1_AT_OrtoGram neq 1><cfset auxchckvlr = 0></cfif>   
        <input type="hidden" name="facameta1atortogram_#grpitm#" id="facameta1atortogram_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta1_AT_CCCP neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta1atcccp_#grpitm#" id="facameta1atcccp_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta1_AE_Tecn neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta1aetech_#grpitm#" id="facameta1aetech_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta1_AE_Prob neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta1aeprob_#grpitm#" id="facameta1aeprob_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta1_AE_Valor neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta1aevalo_#grpitm#" id="facameta1aevalo_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta1_AE_Cosq neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta1aecosq_#grpitm#" id="facameta1aecosq_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta1_AE_Norma neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta1aenorma_#grpitm#" id="facameta1aenorma_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta1_AE_Docu neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta1aedocu_#grpitm#" id="facameta1aedocu_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta1_AE_Class neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta1aeclass_#grpitm#" id="facameta1aeclass_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta1_AE_Orient neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta1aeorient_#grpitm#" id="facameta1aeorient_#grpitm#" value="#auxchckvlr#"> 
        <input type="hidden" name="facameta1pontos_#grpitm#" id="facameta1pontos_#grpitm#" value="#form.meta1_pto#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta2_AR_Falta neq 1><cfset auxchckvlr = 0></cfif>
        <input type="hidden" name="facameta2arfalta_#grpitm#" id="facameta2arfalta_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta2_AR_Troca neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta2artroca_#grpitm#" id="facameta2artroca_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta2_AR_Nomen neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta2arnomen_#grpitm#" id="facameta2arnomen_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta2_AR_Ordem neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta2arordem_#grpitm#" id="facameta2arordem_#grpitm#" value="#auxchckvlr#">
        <cfset auxchckvlr = 1>
        <cfif rsItem.FACA_Meta2_AR_Prazo neq 1><cfset auxchckvlr = 0></cfif>  
        <input type="hidden" name="facameta2arprazo_#grpitm#" id="facameta2arprazo_#grpitm#" value="#auxchckvlr#">
        <input type="hidden" name="facameta2pontos_#grpitm#" id="facameta2pontos_#grpitm#" value="#form.meta2_pto#">
        <cfset form.arearevisor = ''>
        <cfset form.areainspetor = ''>
        <cfset form.areaiscoi = ''>
        <cfset form.areaisgcin = ''>
        <cfif FACA_Avaliacao neq ''>
            <cfset form.arearevisor = trim(#rsItem.FACA_Consideracao_Revisor#)>
            <cfset form.areainspetor = trim(#rsItem.FACA_Consideracao_Avaliador#)>
            <cfset form.areaiscoi = trim(#rsItem.FACA_Consideracao_SCOI#)>
            <cfset form.areaisgcin = trim(#rsItem.FACA_Consideracao_SGCIN#)>
        </cfif>        
        <input type="hidden" name="facaconsideracaorevisor_#grpitm#" id="facaconsideracaorevisor_#grpitm#" value="#form.arearevisor#">
        <input type="hidden" name="facaconsideracaoavaliador_#grpitm#" id="facaconsideracaoavaliador_#grpitm#" value="#form.areainspetor#">
        <input type="hidden" name="facaconsideracaoscoi_#grpitm#" id="facaconsideracaoscoi_#grpitm#" value="#form.areaiscoi#">
        <input type="hidden" name="facaconsideracaosgcin_#grpitm#" id="facaconsideracaosgcin_#grpitm#" value="#form.areaisgcin#">
    </cfloop>
        <input type="hidden" name="grpacesso" id="grpacesso" value="#grpacesso#">
        <input type="hidden" name="grp" id="grp" value="#grp#">
        <input type="hidden" name="itm" id="itm" value="#itm#">
        <input type="hidden" name="matravaliador" id="matravaliador" value="#rsItem.RIP_MatricAvaliador#">      
    </cfoutput>
</form>
</body>


<script src="../jquery-3.7.1.min.js"></script>


<script src="public/bootstrap/bootstrap.bundle.min.js"></script>
<script src="public/jquery-3.7.1.min.js"></script>
<script>
    function ajustar(meta,matr,ptob,result) {
      //  ajustar(a,vlx,percmeta1);    
        //    alert('ajustar ' + meta + matr + '  ' + ptob + '  ' + result);
                        //var dadosNome = $("#ffimeta1pontuacaoobtida_85051071").val();
        if (meta == 1) {
            $("#ffimeta1pontuacaoobtida_" + matr).val(ptob);
            $("#ffimeta1resultado_" + matr).val(result);
            
         //   alert($("#ffimeta1pontuacaoobtida_" + matr).val());
         //   alert($("#ffimeta1resultado_" + matr).val());
        }
        if (meta == 2) {
            $("#ffimeta2pontuacaoobtida_" + matr).val(ptob);
            $("#ffimeta2resultado_" + matr).val(result);
            
           // alert($("#ffimeta2pontuacaoobtida_" + matr).val());
           // alert($("#ffimeta2resultado_" + matr).val());
        }
    }
//=============================================================
        function considerarinspetor(a,b){
           //alert($("#areainspetor_" + a).val());
           $("#facaconsideracaoavaliador_" + a).val(b);
           // alert(a + '  ' + b + '  ' + $("#facaconsideracaoavaliador_702_3").val());
        }
//=============================================================
        function considerarrevisor(a,b){
           //alert($("#arearevisor_" + a).val());
           $("#facaconsideracaorevisor_" + a).val(b);
           // alert(a + '  ' + b + '  ' + $("#facaconsideracaoavaliador_702_3").val());
        }  
//=============================================================
        function considerarscoi(a,b){
           //alert($("#arearevisor_" + a).val());
           $("#facaconsideracaoscoi_" + a).val(b);
           // alert(a + '  ' + b + '  ' + $("#facaconsideracaoavaliador_702_3").val());
        }   
//=============================================================
        function considerarsgcin(a,b){
           //alert($("#arearevisor_" + a).val());
           $("#facaconsideracaosgcin_" + a).val(b);
           // alert(a + '  ' + b + '  ' + $("#facaconsideracaoavaliador_702_3").val());
        }                           
//=============================================================
    function atualizarponto(a,e,f){
        
        var vlr =0;
        if (a) {vlr = 1;}
        //alert(a + ' ' + e + ' ' + f + ' ' + vlr);
        var f = f.substring(6,12);
       // alert(a + ' ' + e + ' ' + f + ' ' + vlr);
        // meta1
        if(f == 'atorgr') {$("#facameta1atortogram_" + e).val(vlr);}
        if(f == 'atcccp') {$("#facameta1atcccp_" + e).val(vlr);}
        if(f == 'aetecn') {$("#facameta1aetech_" + e).val(vlr);}
        if(f == 'aeprob') {$("#facameta1aeprob_" + e).val(vlr);}
        if(f == 'aevalo') {$("#facameta1aevalo_" + e).val(vlr);}
        if(f == 'aecsqc') {$("#facameta1aecosq_" + e).val(vlr);}
        if(f == 'aenorm') {$("#facameta1aenorma_" + e).val(vlr);}
        if(f == 'aedocm') {$("#facameta1aedocu_" + e).val(vlr);}
        if(f == 'aeclas') {$("#facameta1aeclass_" + e).val(vlr);}
        if(f == 'orient') {$("#facameta1aeorient_" + e).val(vlr);}
        //meta2
        if(f == 'arfalt') {$("#facameta2arfalta_" + e).val(vlr);}
        if(f == 'artroc') {$("#facameta2artroca_" + e).val(vlr);}
        if(f == 'arnomc') {$("#facameta2arnomen_" + e).val(vlr);}
        if(f == 'arorde') {$("#facameta2arordem_" + e).val(vlr);}
        if(f == 'arpraz') {$("#facameta2arprazo_" + e).val(vlr);}
    }
//=======================================================================
   function validarform(){
    if (document.facin.meta3_dtplanej.value==''){
            alert("Falta informar o campo: Data Transmissão Planejada!");
            document.facin.meta3_dtplanej.focus();
            return false;
        }
        document.formx.submit();  
   }
 // ================================================================  

</script>
     
</html>