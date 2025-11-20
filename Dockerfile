FROM registry.redhat.io/ansible-automation-platform-26/ansible-dev-tools-rhel9@sha256:6df1c849d33465fb8b5e05451a1249722440a8e50330e403107968bebb150e2b AS builder

WORKDIR /tmp/source

COPY meta/ meta/
COPY roles/ roles/
COPY galaxy.yml .
COPY requirements.yml .
COPY LICENSE .

USER root

RUN ansible-galaxy collection build --force

FROM registry.redhat.io/ubi10-minimal@sha256:649f7ce8082531148ac5e45b61612046a21e36648ab096a77e6ba0c94428cf60

LABEL vendor="Red Hat, Inc.x"
LABEL url="https://www.redhat.com"
LABEL distribution-scope="private"
LABEL version="1.3.0"
LABEL description="Ansible collection to automate the deployment of the Red Hat Trusted Artifact Signer (RHTAS) service on Red Hat Enterprise Linux (RHEL)."
LABEL summary="Ansible Collection for Red Hat Trusted Artifact Signer"
LABEL com.redhat.component="rhtas-ansible-collection"
LABEL name="rhtas-ansible-collection"
LABEL io.k8s.description="The image for the rhtas-ansible collection."

COPY LICENSE /licenses/LICENSE
COPY --from=builder /tmp/source/redhat-artifact_signer-*.tar.gz /releases/
USER 65532:65532
