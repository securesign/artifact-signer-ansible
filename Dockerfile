FROM registry.redhat.io/ansible-automation-platform-25/ansible-dev-tools-rhel8@sha256:9db0f226660e954b4dce2910d14a7ce0245a2222e5af43e6375a0d673253e94e as builder

WORKDIR /tmp/source

COPY meta/ meta/
COPY roles/ roles/
COPY galaxy.yml .
COPY requirements.yml .
COPY LICENSE .

USER root

RUN ansible-galaxy collection build --force

USER 1001

FROM scratch

COPY LICENSE /licenses/LICENSE
COPY --from=builder /tmp/source/redhat-artifact_signer-*.tar.gz /releases/
