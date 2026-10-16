"""Check network-access refusal using mocked AWS responses; no cloud calls."""
from contextlib import ExitStack
import importlib.util
import io
import json
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('aws_guard', Path(__file__).parents[1] / 'aws-guard.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ClientAccessTests(unittest.TestCase):
    def verify(self, current, credits='10'):
        plan = {'accountId': module.PROJECT_ID, 'accountPlanType': 'FREE',
                'accountPlanStatus': 'ACTIVE', 'accountPlanRemainingCredits': {'amount': credits}}
        responses = [
            {'Account': module.PROJECT_ID}, plan,
            {'cluster': {'endpoint': 'https://homework.invalid',
                         'resourcesVpcConfig': {'publicAccessCidrs': ['192.0.2.8/32']}}},
            {'clusters': [{'cluster': {'server': 'https://homework.invalid'}}],
             'users': [{'user': {'exec': {'command': 'aws', 'env': [
                 {'name': 'AWS_PROFILE', 'value': module.PROFILE}]}}}]},
        ]
        with ExitStack() as stack:
            stack.enter_context(patch.object(module.subprocess, 'check_output',
                side_effect=[json.dumps(item) for item in responses]))
            stack.enter_context(patch.object(module.urllib.request, 'urlopen',
                return_value=io.BytesIO(current.encode())))
            return module.check('/private/kubeconfig', check_client_ip=True)

    def test_current_allowed_ip_passes(self):
        self.assertEqual(self.verify('192.0.2.8')['accountPlanType'], 'FREE')

    def test_changed_ip_is_refused_before_connecting_to_kubernetes(self):
        with self.assertRaisesRegex(SystemExit, 'network changed'):
            self.verify('198.51.100.9')

    def test_empty_credits_remain_refused(self):
        with self.assertRaisesRegex(SystemExit, 'credits'):
            self.verify('192.0.2.8', credits='0')


if __name__ == '__main__':
    unittest.main()
