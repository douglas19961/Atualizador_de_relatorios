
select
(padrao) as padrao,
--(info||';') AS info,
(contadebito) AS contadebito,
(contacredito) AS contacredito,
(descricao) as descricao,
valor,
datalanctxt,
data_alteracao,
cod_registro,
cod_lanc_financeiro,
status,
cod_empresa
from
--inicio para union
(
select
padrao,
info,
contadebito,
contacredito,
descricao as descricao,
valor,
valortxt,
datalanctxt,
data_alteracao,
cod_registro,
cod_lanc_financeiro,
status,
cod_empresa
from
(
SELECT
--LANCAMENTOS FINANCEIROS
CASE WHEN CONTADEBITO IS NOT NULL AND CONTACREDITO IS NOT NULL THEN
	'101'
	WHEN CONTADEBITO IS NOT NULL AND CONTACREDITO IS NULL THEN
	'102'
	WHEN CONTADEBITO IS NULL AND CONTACREDITO IS NOT NULL THEN
	'103'
	END AS PADRAO,
 INFO,
 COALeSCE(contadebito,'0000000000') as contadebito,
 COALeSCE(contacredito,'0000000000') as contacredito,
descricao,
valor,
valortxt,
datalanctxt,
data_alteracao,
cod_registro,
cod_lanc_financeiro,
status,
cod_empresa,
filtro
  FROM
(
SELECT
        'X  'info ,
	--DEBITO
	--VERIFICA SE O CAMPO NUMERO DE INTEGRAÇÃO FOI PREENCHIDO COM 100000 SE TRUE (PEGA DEPARAÇÃO DO clifor_protheus SE EXISTIR, SENÃO PEGA clifor_protheus)
	--CASO CONTRARIO (PEGA DEPARAÇÃO DA CONTA SE EXISTIR, SENÃO PEGA O NUMERO DA CONTA)
	lpad( --preenche 0 esquerda cuidar parametro no final lpad(campo,10,'0')
	(CASE
		WHEN cdebito.numero = '100000' THEN COALESCE(dicdebito.dic_numero_conta, to_char(cast(pes.clifor_protheus as bigint), 'FM9999999999'),'888888')
		ELSE COALESCE(dipdebito.dip_numero_conta, (cdebito.numero))
	END),10,'0') as contaDebito,
        lpad(--preenche 0 esquerda cuidar parametro no final lpad(campo,10,'0')
	(CASE 	
		WHEN ccredito.numero = '100000' THEN COALESCE(diccredito.dic_numero_conta, to_char(cast(pes.clifor_protheus as bigint), 'FM9999999999'),'888888')
		ELSE COALESCE(dipcredito.dip_numero_conta, ccredito.numero)
	END),10,'0')as contaCredito,
        substring ( ---descricao passando tamanho 40 iniciando em 0 from 0 for 40)
        lf.nome_lancamento_padrao || ' CFE DOC. ' || COALESCE(lf.numero_documento, '') || ' ' || COALESCE(pes.nome, '')from 0 for 255) as descricao,
        lf.valor,
        lf.valor as ValorTxt,
	lf.data_movimento dataLancTxt,
	lf.data_alteracao,
	lf.cod_registro,
	lf.cod_lanc_financeiro,
(select case when cod_transacao is not null and not (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_cred%') and not (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_deb%') then 'ALTERADO' ELSE 'BAIXA' END AS STATUS from auditor.transactions_audit
		where tipo_evento = 'UPDATE'
		and date(data_hora) < CURRENT_DATE -1
                AND aplicacao NOT ILIKE 'SigServer%'
		AND cod_registro = lf.cod_registro
		and (cast(colunas_alteradas as char(200)) like '%cod_pessoa%' or cast(colunas_alteradas as char(200)) like '%valor%' or (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_cred%') or (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_deb%')
			or cast(colunas_alteradas as char(200)) like '%numero_documento%') limit 1) AS status,
	lf.cod_empresa,
	cast(lf.cod_plano_credito as varchar) ||'-'|| cast(lf.cod_plano_debito as varchar) as filtro 		
FROM lancamentos_financeiros lf
LEFT JOIN plano_contas ccredito ON lf.cod_plano_credito=ccredito.cod_plano
LEFT JOIN plano_contas cdebito ON lf.cod_plano_debito=cdebito.cod_plano
LEFT JOIN pessoas pes ON lf.cod_pessoa=pes.cod_pessoa
LEFT JOIN pessoas emp ON lf.cod_empresa=emp.cod_pessoa
LEFT JOIN dtc_integrador_plano_conta dipdebito  ON (cdebito.numero=dipdebito.dip_numero AND lf.cod_empresa=dipdebito.dip_loja)
LEFT JOIN dtc_integrador_plano_conta dipcredito ON (ccredito.numero=dipcredito.dip_numero AND lf.cod_empresa=dipcredito.dip_loja)
LEFT JOIN dtc_integrador_clifor dicdebito ON (cast(pes.clifor_protheus as bigint)=dicdebito.dic_clifor AND lf.cod_empresa=dicdebito.dic_loja)
LEFT JOIN dtc_integrador_clifor diccredito ON (cast(pes.clifor_protheus as bigint)=diccredito.dic_clifor AND lf.cod_empresa=diccredito.dic_loja)
--CONDIÇÕES
WHERE
DATE(lf.data_alteracao) BETWEEN :data_Alteracao and  CURRENT_DATE - :Dataanterior  
AND lf.situacao = 2
AND (ccredito.numero <> '999999' or cdebito.numero <> '999999')
AND lf.fase_lanc IS NOT true
AND lf.cod_lancamento_padrao NOT IN ('34','150','123','145','146')
---filtra <> transferencia por baixa contas a pagar
)as prim
where --filtro <> '727-422'
((filtro <> '727-422') or (filtro is null))
)as ult
UNION ALL
(SELECT
--vendas
--COLUNAS
 '101' padrao,
        'X  'info,
	lpad( --preenche 0 esquerda cuidar parametro no final lpad(campo,10,'0')
	(CASE
		WHEN cdebito.numero = '100000' THEN COALESCE(dicdebito.dic_numero_conta, to_char(cast(pes.clifor_protheus as bigint), 'FM9999999999'),'888888')
		ELSE COALESCE(dipdebito.dip_numero_conta, cdebito.numero)
	END) ,10,'0')contaDebito,
	lpad( --preenche 0 esquerda cuidar parametro no final lpad(campo,10,'0')
	(CASE 	
		WHEN ccredito.numero = '100000' THEN COALESCE(diccredito.dic_numero_conta, to_char(cast(pes.clifor_protheus as bigint), 'FM9999999999'))
		ELSE COALESCE(dipcredito.dip_numero_conta, ccredito.numero)
	END),10,'0') contaCredito,
	substring ( ---descricao passando tamanho 40 iniciando em 0 from 0 for 40)
        'VENDA '||
        (CASE WHEN LF.cod_lancamento_padrao = 34 THEN 'NFE ' ELSE 'NFCE ' END)
	 || 'DATA: ' || lf.data_movimento from 0 for 255)descricao,
	 lf.valor,

	SUM(lf.valor) as ValorTxt,
	lf.data_movimento dataLancTxt,
	lf.data_alteracao,
	lf.cod_registro,
	lf.cod_lanc_financeiro,
(select case when cod_transacao is not null and not (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_cred%') and not (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_deb%') then 'ALTERADO' ELSE 'BAIXA' END AS STATUS from auditor.transactions_audit
		where tipo_evento = 'UPDATE'
		AND cod_registro = lf.cod_registro
                AND aplicacao NOT ILIKE 'SigServer%'
		and date(data_hora) < CURRENT_DATE -1
       		and (cast(colunas_alteradas as char(200)) like '%cod_pessoa%' or cast(colunas_alteradas as char(200)) like '%valor%' or (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_cred%') or (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_deb%')
                 or cast(colunas_alteradas as char(200)) like '%numero_documento%') limit 1) AS status,
	lf.cod_empresa		
FROM lancamentos_financeiros lf
LEFT JOIN plano_contas ccredito ON lf.cod_plano_credito=ccredito.cod_plano
LEFT JOIN plano_contas cdebito ON lf.cod_plano_debito=cdebito.cod_plano
LEFT JOIN pessoas pes ON lf.cod_pessoa=pes.cod_pessoa
LEFT JOIN pessoas emp ON lf.cod_empresa=emp.cod_pessoa
LEFT JOIN dtc_integrador_plano_conta dipdebito  ON (cdebito.numero=dipdebito.dip_numero AND lf.cod_empresa=dipdebito.dip_loja)
LEFT JOIN dtc_integrador_plano_conta dipcredito ON (ccredito.numero=dipcredito.dip_numero AND lf.cod_empresa=dipcredito.dip_loja)
LEFT JOIN dtc_integrador_clifor dicdebito ON (cast(pes.clifor_protheus as bigint)=dicdebito.dic_clifor AND lf.cod_empresa=dicdebito.dic_loja)
LEFT JOIN dtc_integrador_clifor diccredito ON (cast(pes.clifor_protheus as bigint)=diccredito.dic_clifor AND lf.cod_empresa=diccredito.dic_loja)
--CONDIÇÕES
WHERE
lf.situacao = 2
and DATE(lf.data_alteracao) BETWEEN :data_Alteracao and  CURRENT_DATE -:Dataanterior
AND (ccredito.numero <> '999999' or cdebito.numero <> '999999')

AND lf.fase_lanc IS NOT true
AND lf.cod_lancamento_padrao IN ('34','150')
GROUP BY 1,2,3,4,5,6,8,9,10,11,12,13) 	
UNION ALL
(Select
 '101' padrao,
'X  'info,
	lpad( --preenche 0 esquerda cuidar parametro no final lpad(campo,10,'0')
	(CASE
		WHEN conta_debitada.numero = '100000' THEN COALESCE(to_char(cast(pe.clifor_protheus as bigint), 'FM9999999999'),'888888')
		ELSE (conta_debitada.numero)
	END),10,'0') as contaDebito,
 '1105010001' contaCredito,
        substring ( ---descricao passando tamanho 40 iniciando em 0 from 0 for 40)
        lf.nome_lancamento_padrao || ' CFE DOC. ' || COALESCE(o1.numero_documento, '') || ' ' || COALESCE(pe.nome, '')from 0 for 255) as descricao,
        bl.valor,
        bl.valor as ValorTxt,
	lf.data_movimento dataLancTxt,
	lf.data_alteracao,
	lf.cod_registro,
	lf.cod_lanc_financeiro,
(select case when cod_transacao is not null and not (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_cred%') and not (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_deb%') then 'ALTERADO' ELSE 'BAIXA' END AS STATUS from auditor.transactions_audit
		where tipo_evento = 'UPDATE'
                AND aplicacao NOT ILIKE 'SigServer%'
				and date(data_hora) < CURRENT_DATE -1
		AND cod_registro = TRF.cod_registro
				and (cast(colunas_alteradas as char(200)) like '%cod_pessoa%' or cast(colunas_alteradas as char(200)) like '%valor%' or (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_cred%') or (cast(colunas_alteradas as char(200)) like '%data_fim_baixa_deb%')
                 or cast(colunas_alteradas as char(200)) like '%numero_documento%') limit 1) AS status,
	trf.cod_empresa_origem
from lancamentos_financeiros_transf trf
left join lancamentos_financeiros lf on (trf.cod_lanc_financeiro = lf.cod_lanc_financeiro)
left join baixa_lancamentos bl on (trf.cod_lanc_origem = bl.cod_lanc_baixa)
left join pessoas emptrf on (trf.cod_empresa_origem = emptrf.cod_pessoa)
left join pessoas emporigem on (trf.cod_empresa_origem = emporigem.cod_pessoa)
left join lancamentos_financeiros o1 on (bl.cod_lanc_pendencia = o1.cod_lanc_financeiro)
left join pessoas pe on (o1.cod_pessoa = pe.cod_pessoa)
left join plano_contas conta_debitada on (o1.cod_plano_credito= conta_debitada.cod_plano)
left join plano_contas conta_creditada on (lf.cod_plano_credito= conta_creditada.cod_plano)
where
trf.cod_lanc_financeiro = lf.cod_lanc_financeiro
AND DATE(lf.data_alteracao) BETWEEN :data_Alteracao and  CURRENT_DATE -:Dataanterior         
AND lf.cod_plano_debito = 728
and lf.cod_lancamento_padrao =638
order by emporigem.nome, bl.valor
)
) as geral
order by datalanctxt

