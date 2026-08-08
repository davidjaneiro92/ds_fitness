# ADR-0001: Gerência de estado, injeção de dependência e navegação (GetX)

- **Status:** Aceito
- **Data:** 2026-06-24
- **Decisores:** Time / Tech Lead
- **Contexto da revisão:** decisão alinhada à postura de **preservar a stack atual** (ver [documentation-stance.md](../../00-overview/documentation-stance.md)).

## Contexto
O legado usa **GetX** (`get` 4.7.2) para as três responsabilidades — estado reativo, injeção de dependência e navegação — em produção, de forma consolidada e dominada pelo time. O objetivo do template é **preservar** essa fundação, não substituí-la.

## Decisão
**Manter GetX como base de estado, DI e navegação** no Template Corporativo:
- **Estado:** `Rx`/`.obs` + `Obx`/`GetX` em `GetxController`.
- **DI:** `Get.put`/`Get.lazyPut` registrando **por interface** (`Get.put<I>(Impl)`).
- **Navegação:** `GetMaterialApp` + `getPages` + enum centralizado de rotas.

As melhorias adotadas usam o **próprio GetX**, sem trocar de tecnologia:
1. Preferir `Get.lazyPut`/`Bindings` a `Get.put` eager quando fizer sentido.
2. Injetar repositórios via `Get.find()` (não `new`).
3. Usar `Rx<T?>` nullable em vez de objetos/datas sentinela.
4. Adicionar guards de rota via `GetMiddleware` quando necessário.

## Alternativas consideradas
- **Riverpod + go_router + get_it:** registrado apenas como conhecimento ("consideração futura"). **Não adotado** — exigiria troca de stack, contrária ao objetivo de preservação e ao domínio já consolidado do time.

## Consequências
- ➕ Continuidade tecnológica; curva zero para o time; reuso direto do código existente.
- ➕ Menos risco: a fundação já está validada em produção.
- ➖ Dívidas conhecidas do GetX (acoplamento das 3 responsabilidades) permanecem — mitigadas pelas boas práticas acima.
- 🔭 Reavaliação de stack fica para o futuro, somente se houver motivo técnico concreto.
