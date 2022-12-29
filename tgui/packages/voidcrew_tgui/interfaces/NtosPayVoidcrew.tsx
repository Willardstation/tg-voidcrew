import { NtosPay } from '../../tgui/interfaces/NtosPay';
import { useBackend, useSharedState } from '../../tgui/backend';
import { NtosWindow } from '../../tgui/layouts';
import { Stack, Tabs, Table } from '../../tgui/components';

export const NtosPayVoidcrew = (props, context) => {
  const { data } = useBackend(context);
  const NTOS_PAY = 1;
  const ALL_ACCOUNTS = 2;
  const [screenmode, setScreenmode] = useSharedState(
    context,
    'tab_main',
    NTOS_PAY
  );

  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid textAlign="center">
              <Tabs.Tab
                color="Green"
                selected={screenmode === NTOS_PAY}
                onClick={() => setScreenmode(NTOS_PAY)}>
                Transaction History
              </Tabs.Tab>
              <Tabs.Tab
                Color="Blue"
                selected={screenmode === ALL_ACCOUNTS}
                onClick={() => setScreenmode(ALL_ACCOUNTS)}>
                All Connected Accounts
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {screenmode === NTOS_PAY && <NtosPay />}
            {screenmode === ALL_ACCOUNTS && <AllAccounts />}
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

type Info = {
  all_accounts: string[];
};

const AllAccounts = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { all_accounts } = data;

  return (
    <Table>
      {all_accounts.map((account) => (
        <Table.Row key={account} className="candystripe">
          <Table.Cell width="100px">{account}</Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
