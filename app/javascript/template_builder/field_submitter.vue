<template>
  <div class="dropdown">
    <label
      v-if="compact"
      tabindex="0"
      :title="selectedSubmitter.name"
      class="cursor-pointer text-base-100 flex h-full items-center justify-center"
    >
      <button
        class="mx-1 w-3 h-3 rounded-full"
        :class="colors[submitters.indexOf(selectedSubmitter)]"
      />
    </label>
    <label
      v-else
      tabindex="0"
      class="cursor-pointer rounded-md p-2 border border-base-300 w-full flex justify-between"
    >
      <div class="flex items-center space-x-2">
        <span
          class="w-3 h-3 rounded-full"
          :class="colors[submitters.indexOf(selectedSubmitter)]"
        />
        <Contenteditable
          v-model="selectedSubmitter.name"
          class="cursor-text"
          :icon-inline="true"
          :icon-width="18"
          @update:model-value="$emit('name-change', selectedSubmitter)"
        />
      </div>
      <span class="flex items-center">
        <IconPlus
          width="18"
          height="18"
        />
      </span>
    </label>
    <ul
      tabindex="0"
      :class="menuClasses"
      @click="closeDropdown"
    >
      <li
        v-for="(submitter, index) in submitters"
        :key="submitter.uuid"
      >
        <a
          href="#"
          class="flex px-2 group justify-between items-center"
          :class="{ 'active': submitter === selectedSubmitter }"
          @click.prevent="selectSubmitter(submitter)"
        >
          <span class="py-1 flex items-center">
            <span
              class="rounded-full w-3 h-3 ml-1 mr-3"
              :class="colors[index]"
            />
            <span>
              {{ submitter.name }}
            </span>
          </span>
          <button
            v-if="!compact && submitters.length > 1"
            class="hidden group-hover:block px-2"
            @click.stop="remove(submitter)"
          >
            <IconTrashX :width="18" />
          </button>
        </a>
      </li>
      <li v-if="submitters.length < 5">
        <a
          href="#"
          class="flex px-2"
          @click.prevent="addSubmitter"
        >
          <IconUserPlus
            :width="20"
            :stroke-width="1.6"
          />
          <span class="py-1">
            Add Submitter
          </span>
        </a>
      </li>
    </ul>
  </div>
</template>

<script>
import { IconUserPlus, IconTrashX, IconPlus } from '@tabler/icons-vue'
import Contenteditable from './contenteditable'
import { v4 } from 'uuid'

export default {
  name: 'FieldSubmitter',
  components: {
    IconUserPlus,
    Contenteditable,
    IconPlus,
    IconTrashX
  },
  props: {
    submitters: {
      type: Array,
      required: true
    },
    compact: {
      type: Boolean,
      required: false,
      default: false
    },
    modelValue: {
      type: String,
      required: true
    },
    menuClasses: {
      type: String,
      required: false,
      default: 'dropdown-content menu p-2 shadow bg-base-100 rounded-box w-full z-10'
    }
  },
  emits: ['update:model-value', 'remove', 'new-submitter', 'name-change'],
  computed: {
    colors () {
      return [
        'bg-red-500',
        'bg-sky-500',
        'bg-emerald-500',
        'bg-yellow-300',
        'bg-purple-600'
      ]
    },
    names () {
      return [
        'First Submitter',
        'Second Submitter',
        'Third Submitter',
        'Fourth Submitter',
        'Fifth Submitter'
      ]
    },
    selectedSubmitter () {
      return this.submitters.find((e) => e.uuid === this.modelValue)
    }
  },
  methods: {
    selectSubmitter (submitter) {
      this.$emit('update:model-value', submitter.uuid)
    },
    remove (submitter) {
      if (window.confirm('Are you sure?')) {
        this.$emit('remove', submitter)
      }
    },
    addSubmitter () {
      const newSubmitter = {
        name: this.names[this.submitters.length],
        uuid: v4()
      }

      this.submitters.push(newSubmitter)

      this.$emit('update:model-value', newSubmitter.uuid)
      this.$emit('new-submitter', newSubmitter)
    },
    closeDropdown () {
      document.activeElement.blur()
    }
  }
}
</script>
